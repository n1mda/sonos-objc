//
//  SonosDiscover.m
//  Sonos Controller
//
//  Created by Axel Möller on 21/11/13.
//  Copyright (c) 2013 Appreviation AB. All rights reserved.
//

#import "SonosDiscover.h"
#import "XMLReader.h"
#import "SonosController.h"

typedef void (^findDevicesBlock)(NSArray *ipAddresses);

@interface SonosDiscover ()
- (void)findDevices:(findDevicesBlock)block;
- (void)stopDiscovery;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) findDevicesBlock completionBlock;
@property (nonatomic, strong) NSArray *ipAddressesArray;
@end

@implementation SonosDiscover

+ (void)discoverControllers:(void (^)(NSArray *, NSError *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SonosDiscover *discover = [[SonosDiscover alloc] init];
        [discover findDevices:^(NSArray *ipAdresses) {
            NSMutableArray *devices = [[NSMutableArray alloc] init];
            if (ipAdresses.count > 0) {
                NSString *ipAddress = [ipAdresses objectAtIndex:0];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/status/topology", ipAddress]];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
                [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                    NSHTTPURLResponse *hResponse = (NSHTTPURLResponse*)response;
                    if (hResponse.statusCode == 200){
                        NSDictionary *responseDictionary = [XMLReader dictionaryForXMLData:data error:&error];
                        NSArray *inputDictionaryArray = responseDictionary[@"ZPSupportInfo"][@"ZonePlayers"][@"ZonePlayer"];
                        
                        for (NSDictionary *dictionary in inputDictionaryArray){
                            NSString *name = dictionary[@"text"];
                            NSString *coordinator = dictionary[@"coordinator"];
                            NSString *uuid = dictionary[@"uuid"];
                            NSString *group = dictionary[@"group"];
                            NSString *ip = [[dictionary[@"location"] stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"/xml/device_description.xml" withString:@""];
                            NSArray *location = [ip componentsSeparatedByString:@":"];
                            SonosController *controllerObject = [[SonosController alloc] initWithIP:[location objectAtIndex:0] port:[[location objectAtIndex:1] intValue]];
                            
                            [devices addObject:@{@"ip": [location objectAtIndex:0], @"port" : [location objectAtIndex:1], @"name": name, @"coordinator": [NSNumber numberWithBool:[coordinator isEqualToString:@"true"] ? YES : NO], @"uuid": uuid, @"group": group, @"controller": controllerObject}];
                            
                        }
                        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                        [devices sortUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
                        completion(devices, error);
                    }
                }];
            } else {
                // No devices found
                completion(nil, nil);
            }
        }];
    });
}

- (void)findDevices:(findDevicesBlock)block {
    self.completionBlock = block;
    self.ipAddressesArray = [NSArray array];
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if(![self.udpSocket bindToPort:0 error:&error]) {
        NSLog(@"Error binding");
    }
    
    if(![self.udpSocket beginReceiving:&error]) {
        NSLog(@"Error receiving");
    }
    
    [self.udpSocket enableBroadcast:TRUE error:&error];
    if(error) {
        NSLog(@"Error enabling broadcast");
    }
    
    NSString *str = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp: discover\"\r\nMX: 3\r\nST: urn:schemas-upnp-org:device:ZonePlayer:1\r\n\r\n";
    [self.udpSocket sendData:[str dataUsingEncoding:NSUTF8StringEncoding] toHost:@"239.255.255.250" port:1900 withTimeout:-1 tag:0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self stopDiscovery];
    });
}

- (void)stopDiscovery {
    [self.udpSocket close];
    self.udpSocket = nil;
    self.completionBlock(self.ipAddressesArray);
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(msg) {
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"http:\\/\\/(.*?)\\/" options:0 error:nil];
        NSArray *matches = [reg matchesInString:msg options:0 range:NSMakeRange(0, msg.length)];
        if (matches.count > 0) {
            NSTextCheckingResult *result = matches[0];
            NSString *matched = [msg substringWithRange:[result rangeAtIndex:0]];
            NSString *ip = [[matched substringFromIndex:7] substringToIndex:matched.length-8];
            self.ipAddressesArray = [self.ipAddressesArray arrayByAddingObject:ip];
        }
    }
}

@end
