//
//  SonosDiscover.m
//  Sonos Controller
//
//  Created by Axel Möller on 21/11/13.
//  Copyright (c) 2013 Appreviation AB. All rights reserved.
//

#import "SonosDiscover.h"

@interface SonosDiscover ()
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@end

@implementation SonosDiscover

- (id)initWithDelegate:(id<SonosDiscoverDelegate>)delegate {
    self = [super init];
    if(self) {
        _delegate = delegate;
    }
    
    return self;
}

- (void)discoverControllersForDuration:(int)seconds {
    NSLog(@"Starting discovery of Sonos Controllers");
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if(![self.udpSocket bindToPort:0 error:&error]) {
        NSLog(@"Error binding");
        [self stopDiscovery];
        return;
    }
    
    if(![self.udpSocket beginReceiving:&error]) {
        NSLog(@"Error receiving");
        [self stopDiscovery];
        return;
    }
    
    [self.udpSocket enableBroadcast:TRUE error:&error];
    if(error) {
        NSLog(@"Error enabling broadcast");
        [self stopDiscovery];
        return;
    }

    NSString *str = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp: discover\"\r\nMX: 3\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1\r\n\r\n";
    [self.udpSocket sendData:[str dataUsingEncoding:NSUTF8StringEncoding] toHost:@"239.255.255.250" port:1900 withTimeout:-1 tag:0];
    
    // Clean up when user wants to
    [self performSelector:@selector(stopDiscovery) withObject:nil afterDelay:seconds];
}

- (void)stopDiscovery {
    [self.udpSocket close];
    self.udpSocket = nil;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(msg) {
        
        // Check if it's a Sonos Device
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"http:\\/\\/(.*?):([0-9]*?)\\/xml\\/device_description\\.xml" options:0 error:nil];
        NSArray *matches = [reg matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
        
        if(matches.count > 0) {
            // Check if it's a player, disregard bridges
            NSRegularExpression *playerReg = [[NSRegularExpression alloc] initWithPattern:@"SERVER.*\\((.*?)\\)" options:0 error:nil];
            NSArray *playerMatches = [playerReg matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
            
            for(NSTextCheckingResult *playerMatch in playerMatches) {
                NSRange player = [playerMatch rangeAtIndex:1];
                NSString *playerString = [msg substringWithRange:player];
                if(![playerString isEqualToString:@"BR100"]) {
                    
                    // Return IP and port
                    for(NSTextCheckingResult *match in matches) {
                        NSRange ip = [match rangeAtIndex:1];
                        NSRange port = [match rangeAtIndex:2];
                        NSString *ipString = [msg substringWithRange:ip];
                        NSString *portString = [msg substringWithRange:port];
                        if([self.delegate respondsToSelector:@selector(foundSonosControllerAtHost:port:)]) {
                            [self.delegate foundSonosControllerAtHost:ipString port:[portString intValue]];
                        }
                    }

                }
            }
        }
    }
}

@end
