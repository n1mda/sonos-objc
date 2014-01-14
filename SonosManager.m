//
//  SonosManager.m
//  Sonos Controller
//
//  Created by Axel Möller on 14/01/14.
//  Copyright (c) 2014 Appreviation AB. All rights reserved.
//

#import "SonosManager.h"

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
        [SonosDiscover discoverControllers:^(NSArray *devices, NSError *error){
            self.allDevices = devices;
            if(self.allDevices.count > 0)
                self.currentDevice = [self.allDevices objectAtIndex:0];
        }];
    }
    return self;
}


@end
