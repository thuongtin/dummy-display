#import "LoginItemController.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation LoginItemController

- (BOOL)isEnabled {
    if (@available(macOS 13.0, *)) {
        return SMAppService.mainAppService.status == SMAppServiceStatusEnabled;
    }
    return NO;
}

- (BOOL)requiresApproval {
    if (@available(macOS 13.0, *)) {
        return SMAppService.mainAppService.status == SMAppServiceStatusRequiresApproval;
    }
    return NO;
}

- (NSString *)statusText {
    if (@available(macOS 13.0, *)) {
        switch (SMAppService.mainAppService.status) {
            case SMAppServiceStatusEnabled:
                return @"Launch at Login: On";
            case SMAppServiceStatusRequiresApproval:
                return @"Launch at Login: Needs Approval";
            case SMAppServiceStatusNotFound:
                return @"Launch at Login: App Not Found";
            case SMAppServiceStatusNotRegistered:
                return @"Launch at Login: Off";
        }
    }
    return @"Launch at Login: Unsupported";
}

- (BOOL)setEnabled:(BOOL)enabled error:(NSError **)error {
    if (@available(macOS 13.0, *)) {
        if (enabled) {
            return [SMAppService.mainAppService registerAndReturnError:error];
        }
        return [SMAppService.mainAppService unregisterAndReturnError:error];
    }

    if (error != nil) {
        *error = [NSError errorWithDomain:@"local.codex.dummy-display"
                                     code:2
                                 userInfo:@{NSLocalizedDescriptionKey: @"Launch at login requires macOS 13 or later."}];
    }
    return NO;
}

@end
