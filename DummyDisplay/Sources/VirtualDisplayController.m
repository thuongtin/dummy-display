#import "VirtualDisplayController.h"
#import <CoreGraphics/CoreGraphics.h>

@interface CGVirtualDisplayDescriptor : NSObject
@property(nonatomic) uint32_t vendorID;
@property(nonatomic) uint32_t productID;
@property(nonatomic) uint32_t serialNum;
@property(nonatomic) uint32_t maxPixelsWide;
@property(nonatomic) uint32_t maxPixelsHigh;
@property(nonatomic) CGSize sizeInMillimeters;
@property(nonatomic, copy) NSString *name;
@property(nonatomic) dispatch_queue_t queue;
@end

@interface CGVirtualDisplayMode : NSObject
- (instancetype)initWithWidth:(uint32_t)width height:(uint32_t)height refreshRate:(double)refreshRate;
@end

@interface CGVirtualDisplaySettings : NSObject
@property(nonatomic) uint32_t hiDPI;
@property(nonatomic, copy) NSArray *modes;
@end

@interface CGVirtualDisplay : NSObject
- (instancetype)initWithDescriptor:(CGVirtualDisplayDescriptor *)descriptor;
- (BOOL)applySettings:(CGVirtualDisplaySettings *)settings;
@property(nonatomic, readonly) uint32_t displayID;
@end

@interface VirtualDisplayController ()
@property(nonatomic, strong, nullable) CGVirtualDisplay *display;
@property(nonatomic) uint32_t displayID;
@property(nonatomic, copy) NSString *statusText;
@end

@implementation VirtualDisplayController

- (instancetype)init {
    self = [super init];
    if (self) {
        _statusText = @"Idle";
    }
    return self;
}

- (BOOL)isActive {
    return self.display != nil;
}

- (BOOL)startWithPreset:(DummyDisplayPreset)preset hiDPI:(BOOL)hiDPI error:(NSError **)error {
    if (self.display != nil) {
        self.statusText = @"Already active";
        return YES;
    }

    CGSize pixelSize = [self pixelSizeForPreset:preset];

    CGVirtualDisplayDescriptor *descriptor = [CGVirtualDisplayDescriptor new];
    descriptor.name = @"Codex Dummy Display";
    descriptor.vendorID = 0x0A1D;
    descriptor.productID = 0xD00D;
    descriptor.serialNum = 20260525;
    descriptor.maxPixelsWide = MAX((uint32_t)pixelSize.width, 3840);
    descriptor.maxPixelsHigh = MAX((uint32_t)pixelSize.height, 2160);
    descriptor.sizeInMillimeters = CGSizeMake(600, 340);
    descriptor.queue = dispatch_get_main_queue();

    CGVirtualDisplay *display = [[CGVirtualDisplay alloc] initWithDescriptor:descriptor];
    if (display == nil) {
        if (error != nil) {
            *error = [self errorWithMessage:@"Could not create virtual display."];
        }
        self.statusText = @"Create failed";
        return NO;
    }

    CGVirtualDisplayMode *mode = [[CGVirtualDisplayMode alloc] initWithWidth:(uint32_t)pixelSize.width
                                                                      height:(uint32_t)pixelSize.height
                                                                 refreshRate:60.0];
    CGVirtualDisplaySettings *settings = [CGVirtualDisplaySettings new];
    settings.hiDPI = hiDPI ? 1 : 0;
    settings.modes = @[ mode ];

    BOOL applied = [display applySettings:settings];
    if (!applied) {
        if (error != nil) {
            *error = [self errorWithMessage:@"Virtual display was created, but applying settings failed."];
        }
        self.statusText = @"Settings failed";
        return NO;
    }

    self.display = display;
    self.displayID = display.displayID;
    self.statusText = [NSString stringWithFormat:@"Active, display ID %u", self.displayID];
    return YES;
}

- (void)stop {
    self.display = nil;
    self.displayID = 0;
    self.statusText = @"Idle";
}

+ (NSArray<NSString *> *)presetTitles {
    return @[
        @"1920 x 1080",
        @"2560 x 1440",
        @"3840 x 2160"
    ];
}

+ (NSString *)descriptionForPreset:(DummyDisplayPreset)preset {
    switch (preset) {
        case DummyDisplayPreset1080p:
            return @"1920 x 1080 at 60 Hz";
        case DummyDisplayPreset1440p:
            return @"2560 x 1440 at 60 Hz";
        case DummyDisplayPreset4K:
            return @"3840 x 2160 at 60 Hz";
    }
}

- (CGSize)pixelSizeForPreset:(DummyDisplayPreset)preset {
    switch (preset) {
        case DummyDisplayPreset1080p:
            return CGSizeMake(1920, 1080);
        case DummyDisplayPreset1440p:
            return CGSizeMake(2560, 1440);
        case DummyDisplayPreset4K:
            return CGSizeMake(3840, 2160);
    }
}

- (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"local.codex.dummy-display"
                               code:1
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
