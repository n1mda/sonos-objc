//
//  SonosManager.h
//  Sonos Controller
//
//  Created by Axel Möller on 14/01/14.
//  Copyright (c) 2014 Appreviation AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SonosController;
@interface SonosManager : NSObject

// Arrays containing all Sonos Devices on network
@property (strong, nonatomic) NSMutableArray *coordinators;
@property (strong, nonatomic) NSMutableArray *slaves;

// The "current" device, ie. the device that acts if we select "play" now
@property (strong, readwrite, nonatomic) SonosController *currentDevice;

+ (id)sharedInstance;

// Returns a copy of all devices, coordinators + slaves
- (NSArray *)allDevices;

@end
