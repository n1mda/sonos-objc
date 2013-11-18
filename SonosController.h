//
//  SonosController.h
//  Sonos Controller
//
//  Created by Axel Möller on 16/11/13.
//  Copyright (c) 2013 Appreviation AB. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import <Foundation/Foundation.h>

@interface SonosController : NSObject

@property (nonatomic, retain) NSString *ip;
@property (nonatomic, assign) int port;

/**
 Creates and returns a Sonos Controller object. By default, the SOAP interface on Sonos Devices operate on port 1400, but use initWithIP:port: if you need to specify another port
 */
- (id)initWithIP:(NSString *)ip_;
- (id)initWithIP:(NSString *)ip_ port:(int)port_;

/**
 All SOAP methods returns asynchronus XML data from the Sonos Device in dictionary format for easy reading.
 Some methods returns slimmed down data, for easier management (Sonos returns a bunch of unneccesary data):
 - trackInfo:
 - mediaInfo:
 - status:
 - browse:
 
 All methods returns a non-empty NSError object on failure
 */

/**
 Plays a track
 
 @param track The Track URI, may be nil to just play current track
 @param block Objective-C block to call on finish
 */
- (void)play:(NSString *)track completion:(void (^)(NSDictionary *, NSError *))block;

/**
 Pause playback
 
 @param block Objective-C block to call on finish
 */
- (void)pause:(void (^)(NSDictionary *, NSError *))block;

/**
 Next track
 
 @param block Objective-C block to call on finish
 */
- (void)next:(void (^)(NSDictionary *, NSError *))block;

/**
 Previous track
 
 @param block Objective-C block to call on finish
 */
- (void)previous:(void (^)(NSDictionary *, NSError *))block;

/**
 Queue a track
 
 @param track The Track URI, may not be nil
 @param block Objective-C block to call on finish
 */
- (void)queue:(NSString *)track completion:(void (^)(NSDictionary *, NSError *))block;

/**
 Get current volume of device.
 This method returns an NSInteger with the volume level (0-100)
 
 @param block Objective-C block to call on finish
 */
- (void)getVolume:(void (^)(NSInteger, NSError *))block;

/**
 Set volume of device
 
 @param volume The volume (0-100)
 @param block Objective-C block to call on finish
 */
- (void)setVolume:(int)volume completion:(void (^)(NSDictionary *, NSError *))block;

/**
 Get current track info. NSDictionary contains (if data available, otherwise empty value):
 - MetaDataAlbum - Album name
 - MetaDataAlbumArtURI - URI to Album art
 - MetaDataCreator - Artist name
 - MetaDataTitle - Track name
 - RelTime - Current playback time
 - Track - The tracks position in the queue, if any
 - TrackDuration - Tracks total length
 - TrackURI - Track URI
 
 @param block Objective-C block to call on finish
 */
- (void)trackInfo:(void (^)(NSDictionary *, NSError *))block;
- (void)mediaInfo:(void (^)(NSDictionary *, NSError *))block;
- (void)status:(void (^)(NSDictionary *, NSError *))block;
- (void)browse:(void (^)(NSDictionary *, NSError *))block;

@end
