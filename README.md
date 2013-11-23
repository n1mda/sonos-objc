sonos-objc
==========

A simple Objective-C API for controlling Sonos Devices

The aim of this repository is to create a simple to use, yet useful API to control Sonos Devices via SOAP. It depends on AFNetworking (iOS and OS X) and XMLReader.h/m (iOS and OS X)

# Usage

```objective-c
#import "SonosDiscover.h"
#import "SonosController.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *sonosDevices;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.devices = [[NSMutableArray alloc] init];
    [SonosDiscover discoverControllers:^(NSArray *devices, NSError *error){
	NSLog(@"Devices: %@", devices);
        for (NSDictionary *device in devices) {
            SonosController *controller = [[SonosController alloc] initWithIP:device[@"ip"] port:[device[@"port"] intValue]];
            [self.sonosDevices addObject:controller];
        }
    }];
}
```

See SonosController.h for usage on how to control devices
