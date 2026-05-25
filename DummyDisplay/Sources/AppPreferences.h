#import <Foundation/Foundation.h>
#import "VirtualDisplayController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppPreferences : NSObject

@property(nonatomic) DummyDisplayPreset selectedPreset;
@property(nonatomic) BOOL hiDPIEnabled;
@property(nonatomic) BOOL autoStartEnabled;

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults;
- (void)save;
- (NSString *)debugStatusText;

@end

NS_ASSUME_NONNULL_END
