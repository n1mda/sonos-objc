//
//  SonosManager.m
//  Sonos Controller
//
//  Created by Axel Möller on 14/01/14.
//  Copyright (c) 2014 Appreviation AB. All rights reserved.
//

#import "SonosManager.h"
#import "SonosController.h"
#import "SonosDiscover.h"

@implementation SonosManager

+ (SonosManager *)sharedInstance {
    static SonosManager *sharedInstanceInstance = nil;
    static dispatch_once_t p;
    dispatch_once(&p, ^{
        sharedInstanceInstance = [[self alloc] init];
    });
    return sharedInstanceInstance;
}

- (id)init {
    self = [super init];
    
    if(self){
        
        self.coordinators = [[NSMutableArray alloc] init];
        self.slaves = [[NSMutableArray alloc] init];
        
        [SonosDiscover discoverControllers:^(NSArray *devices, NSError *error){
            
            [self willChangeValueForKey:@"allDevices"];
            
            // Save all devices
            for(NSDictionary *device in devices) {
                SonosController *controller = [[SonosController alloc] initWithIP:[device valueForKey:@"ip"] port:[[device valueForKey:@"port"] intValue]];
                [controller setGroup:[device valueForKey:@"group"]];
                [controller setName:[device valueForKey:@"name"]];
                [controller setUuid:[device valueForKey:@"uuid"]];
                [controller setCoordinator:[[device valueForKey:@"coordinator"] boolValue]];
                if([controller isCoordinator])
                    [self.coordinators addObject:controller];
                else
                    [self.slaves addObject:controller];
            }
            
            // Add slaves to masters
            for(SonosController *slave in self.slaves) {
                for(SonosController *coordinator in self.coordinators) {
                    if([[coordinator group] isEqualToString:[slave group]]) {
                        [[coordinator slaves] addObject:slave];
                        break;
                    }
                }
            }
            
            // Find current device (this implementation may change in the future)
            if([[self allDevices] count] > 0) {
                [self willChangeValueForKey:@"currentDevice"];
                self.currentDevice = [self.coordinators objectAtIndex:0];
                for(SonosController *controller in self.coordinators) {
                    // If a coordinator is playing, make it the current device
                    [controller playbackStatus:^(BOOL playing, NSDictionary *response, NSError *error){
                        if(playing) self.currentDevice = controller;
                    }];
                }
                [self didChangeValueForKey:@"currentDevice"];
            }
            
            [self didChangeValueForKey:@"allDevices"];
        }];
    }
    
    return self;
}

- (NSArray *)allDevices {
    return [self.coordinators arrayByAddingObjectsFromArray:self.slaves];
}

@end