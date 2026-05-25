#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

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

static void printDisplays(NSString *label) {
    uint32_t count = 0;
    CGGetActiveDisplayList(0, NULL, &count);

    CGDirectDisplayID displays[32] = {0};
    uint32_t cappedCount = MIN(count, 32);
    CGGetActiveDisplayList(cappedCount, displays, &cappedCount);

    printf("%s count=%u", [label UTF8String], count);
    for (uint32_t index = 0; index < cappedCount; index++) {
        printf(" %u", displays[index]);
    }
    printf("\n");
}

int main(void) {
    @autoreleasepool {
        printDisplays(@"before");

        CGVirtualDisplayDescriptor *descriptor = [CGVirtualDisplayDescriptor new];
        descriptor.name = @"Codex Dummy Display";
        descriptor.vendorID = 0x0A1D;
        descriptor.productID = 0xD00D;
        descriptor.serialNum = 20260525;
        descriptor.maxPixelsWide = 3840;
        descriptor.maxPixelsHigh = 2160;
        descriptor.sizeInMillimeters = CGSizeMake(600, 340);
        descriptor.queue = dispatch_get_main_queue();

        CGVirtualDisplay *display = [[CGVirtualDisplay alloc] initWithDescriptor:descriptor];
        if (display == nil) {
            fprintf(stderr, "create failed\n");
            return 2;
        }

        CGVirtualDisplayMode *mode = [[CGVirtualDisplayMode alloc] initWithWidth:2560 height:1440 refreshRate:60.0];
        CGVirtualDisplaySettings *settings = [CGVirtualDisplaySettings new];
        settings.hiDPI = 1;
        settings.modes = @[ mode ];

        BOOL applied = [display applySettings:settings];
        printf("created displayID=%u applied=%s\n", display.displayID, applied ? "true" : "false");
        printDisplays(@"after-create");

        sleep(3);
        display = nil;

        sleep(1);
        printDisplays(@"after-release");
    }

    return 0;
}
