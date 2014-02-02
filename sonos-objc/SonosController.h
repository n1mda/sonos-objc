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

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, assign) int port;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign, getter = isCoordinator) BOOL coordinator;
@property (nonatomic, strong) NSMutableArray *slaves;

/**
 Creates and returns a Sonos Controller object.
 By default, the SOAP interface on Sonos Devices operate on port 1400, but use initWithIP:port: if you need to specify another port
 
 Use SonosManager to create these controllers automatically
 */
- (id)initWithIP:(NSString *)ip_;
- (id)initWithIP:(NSString *)ip_ port:(int)port_;

/**
 All SOAP methods returns asynchronus XML data from the Sonos Device in an NSDictionary format for easy reading.
 Some methods returns quick values that are interesting, eg. getVolume:completion: returns an integer containing the volume,
 together with the entire XML response
 
 All methods returns a non-empty NSError object on failure
 */

/**
 Plays a track
 
 @param track The Track URI, may be nil to just play current track
 @param block Objective-C block to call on finish
 */
- (void)play:(NSString *)track completion:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Plays a track with custom URI Metadata, Spotify etc needs this, see playSpotifyTrack:completion:
 
 @param track The track URI
 @param URIMetaData Metadata XML String
 @param block Objective-C block to call on finish
 */
- (void)play:(NSString *)track URIMetaData:(NSString *)URIMetaData completion:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Plays a Spotify track
 
 @param track Spotify track URI
 @param block Objective-C block to call on finish
 */
- (void)playSpotifyTrack:(NSString *)track completion:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Play track in queue
 
 @param position. Starts counting at 1
 @param block Objective-C block to call on finish
 */
- (void)playQueuePosition:(int)position completion:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Pause playback
 
 @param block Objective-C block to call on finish
 */
- (void)pause:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Toggle playback, pause if playing, play if paused
 BOOL in block function contains current playback state
 
 @param block Objective-C block to call on finish
 */
- (void)togglePlayback:(void (^)(BOOL playing, NSDictionary *response, NSError *error))block;

/**
 Next track
 
 @param block Objective-C block to call on finish
 */
- (void)next:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Previous track
 
 @param block Objective-C block to call on finish
 */
- (void)previous:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Queue a track
 
 @param track The Track URI, may not be nil
 @param block Objective-C block to call on finish
 */
- (void)queue:(NSString *)track replace:(BOOL)replace completion:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Queue a track with custom URI Metadata
 Needed for Spotify etc
 
 @param track The Track URI
 @param URIMetaData URI Metadata XML String
 @param block Objective-C block to call on finish
 */
- (void)queue:(NSString *)track URIMetaData:(NSString *)URIMetaData replace:(BOOL)replace completion:(void (^)(NSDictionary *response, NSError *error))block;

/*
 Queue a Spotify playlist
 eg. spotify:user:aaa:playlist:xxxxxxxxxx
 
 @param playlist The playlist URI
 @param replace Replace current queue
 @param block Objective-C block to call on finish
 */
- (void)queueSpotifyPlaylist:(NSString *)playlist replace:(BOOL)replace completion:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Get current volume of device.
 This method returns an NSInteger with the volume level (0-100)
 
 @param block Objective-C block to call on finish
 */
- (void)getVolume:(void (^)(NSInteger volume, NSDictionary *response, NSError *))block;

/**
 Set volume of device
 
 @param volume The volume (0-100)
 @param block Objective-C block to call on finish
 */
- (void)setVolume:(NSInteger)volume completion:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Get mute status
 
 @param block Objective-C block to call on finish
 */
- (void)getMute:(void (^)(BOOL mute, NSDictionary *response, NSError *error))block;

/**
 Set or unset mute on device
 
 @param mute Bool value
 @param block Objective-C block to call on finish
 */
- (void)setMute:(BOOL)mute completion:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Get current track info.
 
 @param block Objective-C block to call on finish
 */
- (void)trackInfo:(void (^)(NSString *artist, NSString *title, NSString *album, NSURL *albumArt, NSInteger time, NSInteger duration, NSInteger queueIndex, NSString *trackURI, NSString *protocol, NSError *error))block;

- (void)mediaInfo:(void (^)(NSDictionary *response, NSError *error))block;

/**
 Playback status
 Returns playback boolean value in block
 
 @param block Objective-C block to call on finish
 */
- (void)playbackStatus:(void (^)(BOOL playing, NSDictionary *response, NSError *error))block;

/**
 More detailed version of playbackStatus:
 Get status info (playback status). The only interesting data IMO is CurrentTransportState that tells if the playback is active. Thus returns:
 - CurrentTransportState - {PLAYING|PAUSED_PLAYBACK|STOPPED}
 
 @param block Objective-C block to call on finish
 */
- (void)status:(void (^)(NSDictionary *response, NSError *error))block;

- (void)browse:(void (^)(NSDictionary *response, NSError *error))block;

@end