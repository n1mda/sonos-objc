sonos-objc
==========

An Objective-C API for controlling Sonos Devices

The aim of this library is to create a simple to use, yet useful API to control Sonos Devices via SOAP. It depends on AFNetworking (iOS and OS X), CocoaAsyncSocket (iOS and OS X) and XMLReader.h/m (iOS and OS X)

# Installation with CocoaPods

CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like sonos-objc in your projects. See the [Cocoapods Website for more information](http://cocoapods.org/).

**Podfile**

```rb
pod "sonos-objc", "~> 0.1.2"
```

# Usage

```objective-c
#import "SonosManager.h"
#import "SonosController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[SonosManager sharedInstance] addObserver:self forKeyPath:@"allDevices" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	SonosController *controller = [[SonosManager sharedInstance] currentDevice];
    [controller trackInfo:^(NSString *artist, NSString *title, NSString *album, NSURL *albumArt, NSInteger time, NSInteger duration, NSInteger queueIndex, NSString *trackURI, NSString *protocol, NSError *error){
        
        NSLog(@"Artist: %@", artist);
        NSLog(@"Title: %@", title);
        NSLog(@"Album: %@", album);
        NSLog(@"Album Art: %@", albumArt);
        NSLog(@"Time: %d", time);
        NSLog(@"Duration: %d", duration);
        NSLog(@"Place in queue: %d", queueIndex);
        NSLog(@"Track URI: %@", trackURI);
        NSLog(@"Protocol: %@", protocol);
        
    }];
}
```

See SonosController.h for usage on how to control devices
