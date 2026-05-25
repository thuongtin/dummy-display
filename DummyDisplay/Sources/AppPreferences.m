#import "AppPreferences.h"

static NSString * const SelectedPresetKey = @"SelectedPreset";
static NSString * const HiDPIEnabledKey = @"HiDPIEnabled";
static NSString * const AutoStartEnabledKey = @"AutoStartEnabled";

@interface AppPreferences ()
@property(nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation AppPreferences

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults {
    self = [super init];
    if (self) {
        _defaults = defaults;
        [_defaults registerDefaults:@{
            SelectedPresetKey: @(DummyDisplayPreset1440p),
            HiDPIEnabledKey: @YES,
            AutoStartEnabledKey: @NO
        }];
        [self load];
    }
    return self;
}

- (void)load {
    NSInteger preset = [self.defaults integerForKey:SelectedPresetKey];
    if (preset < DummyDisplayPreset1080p || preset > DummyDisplayPreset4K) {
        preset = DummyDisplayPreset1440p;
    }

    self.selectedPreset = (DummyDisplayPreset)preset;
    self.hiDPIEnabled = [self.defaults boolForKey:HiDPIEnabledKey];
    self.autoStartEnabled = [self.defaults boolForKey:AutoStartEnabledKey];
}

- (void)save {
    [self.defaults setInteger:self.selectedPreset forKey:SelectedPresetKey];
    [self.defaults setBool:self.hiDPIEnabled forKey:HiDPIEnabledKey];
    [self.defaults setBool:self.autoStartEnabled forKey:AutoStartEnabledKey];
}

- (NSString *)debugStatusText {
    return [NSString stringWithFormat:@"preset=%ld hiDPI=%@ autoStart=%@",
                                      (long)self.selectedPreset,
                                      self.hiDPIEnabled ? @"true" : @"false",
                                      self.autoStartEnabled ? @"true" : @"false"];
}

@end
