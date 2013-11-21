sonos-objc
==========

A simple Objective-C API for controlling Sonos Devices

The aim of this repository is to create a simple to use, yet useful API to control Sonos Devices via SOAP. It depends on AFNetworking (iOS and OS X) and XMLReader.h/m (iOS and OS X)

# Usage

```objective-c
@interface ViewController ()
@property (nonatomic, strong) SonosDiscover *discovery;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.discovery = [[SonosDiscover alloc] initWithDelegate:self];
    [self.discovery discoverControllersForDuration:10];
}

#pragma mark - SonosDiscoverDelegate methods
- (void)foundSonosControllerAtHost:(NSString *)host port:(int)port {
    NSLog(@"Found Sonos Controller at %@:%d", host, port);
    SonosController *controller = [[SonosController alloc] initWithIP:host port:port];
    [devices addObject:controller];
}
```
To discover sonos devices on a network, use SonosDiscover

Note that if you're using ARC, you need to propertize SonosDiscover with strong, otherwise it will release itself before GCDAsyncUDPSocket has had time to respond with devices

See SonosController.h for usage on how to control devices
