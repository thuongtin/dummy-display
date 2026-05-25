#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DummyDisplayPreset) {
    DummyDisplayPreset1080p = 0,
    DummyDisplayPreset1440p = 1,
    DummyDisplayPreset4K = 2
};

@interface VirtualDisplayController : NSObject

@property(nonatomic, readonly, getter=isActive) BOOL active;
@property(nonatomic, readonly) uint32_t displayID;
@property(nonatomic, copy, readonly) NSString *statusText;

- (BOOL)startWithPreset:(DummyDisplayPreset)preset hiDPI:(BOOL)hiDPI error:(NSError **)error;
- (void)stop;

+ (NSArray<NSString *> *)presetTitles;
+ (NSString *)descriptionForPreset:(DummyDisplayPreset)preset;

@end

NS_ASSUME_NONNULL_END
