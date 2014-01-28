//
//  SonosManager.h
//  Sonos Controller
//
//  Created by Axel Möller on 14/01/14.
//  Copyright (c) 2014 Appreviation AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SonosController.h"
#import "SonosDiscover.h"

@interface SonosManager : NSObject

// Array containing all Sonos Devices on network
@property (strong, nonatomic) NSArray *allDevices;
// The "current" device, ie. the device that acts if we select "play" now
@property (strong, readwrite, nonatomic) SonosController *currentDevice;

+ (id)sharedInstance;

@end
