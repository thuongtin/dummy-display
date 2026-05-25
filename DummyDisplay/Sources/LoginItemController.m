#import "LoginItemController.h"
#import <ServiceManagement/ServiceManagement.h>

static NSString * const LaunchAgentIdentifier = @"local.codex.dummy-display.launch-at-login";

@implementation LoginItemController

- (BOOL)isEnabled {
    if ([self isLaunchAgentEnabled]) {
        return YES;
    }

    if (@available(macOS 13.0, *)) {
        return SMAppService.mainAppService.status == SMAppServiceStatusEnabled;
    }
    return NO;
}

- (BOOL)requiresApproval {
    if ([self shouldUseLaunchAgentFallback]) {
        return NO;
    }

    if (@available(macOS 13.0, *)) {
        return SMAppService.mainAppService.status == SMAppServiceStatusRequiresApproval;
    }
    return NO;
}

- (NSString *)statusText {
    if ([self isLaunchAgentEnabled]) {
        return @"Launch at Login: On";
    }

    if ([self shouldUseLaunchAgentFallback]) {
        return @"Launch at Login: Off";
    }

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
    if ([self shouldUseLaunchAgentFallback] || [self isLaunchAgentEnabled]) {
        return [self setLaunchAgentEnabled:enabled error:error];
    }

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

- (NSString *)debugStatusText {
    NSString *serviceStatus = @"unsupported";
    if (@available(macOS 13.0, *)) {
        serviceStatus = [self textForServiceStatus:SMAppService.mainAppService.status];
    }

    return [NSString stringWithFormat:@"SMAppService=%@ LaunchAgent=%@ Plist=%@",
                                      serviceStatus,
                                      [self isLaunchAgentEnabled] ? @"enabled" : @"disabled",
                                      [self launchAgentPlistURL].path];
}

- (BOOL)shouldUseLaunchAgentFallback {
    if (@available(macOS 13.0, *)) {
        return SMAppService.mainAppService.status == SMAppServiceStatusNotFound;
    }
    return YES;
}

- (NSString *)textForServiceStatus:(SMAppServiceStatus)status API_AVAILABLE(macos(13.0)) {
    switch (status) {
        case SMAppServiceStatusEnabled:
            return @"enabled";
        case SMAppServiceStatusRequiresApproval:
            return @"requires-approval";
        case SMAppServiceStatusNotFound:
            return @"not-found";
        case SMAppServiceStatusNotRegistered:
            return @"not-registered";
    }
}

- (BOOL)isLaunchAgentEnabled {
    NSURL *plistURL = [self launchAgentPlistURL];
    return [[NSFileManager defaultManager] fileExistsAtPath:plistURL.path];
}

- (BOOL)setLaunchAgentEnabled:(BOOL)enabled error:(NSError **)error {
    if (enabled) {
        return [self installLaunchAgent:error];
    }
    return [self removeLaunchAgent:error];
}

- (BOOL)installLaunchAgent:(NSError **)error {
    NSURL *plistURL = [self launchAgentPlistURL];
    NSURL *directoryURL = plistURL.URLByDeletingLastPathComponent;

    if (![[NSFileManager defaultManager] createDirectoryAtURL:directoryURL
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:error]) {
        return NO;
    }

    NSString *bundlePath = NSBundle.mainBundle.bundlePath;
    NSDictionary *plist = @{
        @"Label": LaunchAgentIdentifier,
        @"ProgramArguments": @[
            @"/usr/bin/open",
            @"-gj",
            bundlePath
        ],
        @"RunAtLoad": @YES
    };

    NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:error];
    if (data == nil) {
        return NO;
    }

    if (![data writeToURL:plistURL options:NSDataWritingAtomic error:error]) {
        return NO;
    }

    [self runLaunchctlWithArguments:@[@"bootout", [self userDomain], plistURL.path] allowFailure:YES error:nil];
    return [self runLaunchctlWithArguments:@[@"bootstrap", [self userDomain], plistURL.path] allowFailure:NO error:error];
}

- (BOOL)removeLaunchAgent:(NSError **)error {
    NSURL *plistURL = [self launchAgentPlistURL];

    [self runLaunchctlWithArguments:@[@"bootout", [self userDomain], plistURL.path] allowFailure:YES error:nil];

    if (![[NSFileManager defaultManager] fileExistsAtPath:plistURL.path]) {
        return YES;
    }

    return [[NSFileManager defaultManager] removeItemAtURL:plistURL error:error];
}

- (BOOL)runLaunchctlWithArguments:(NSArray<NSString *> *)arguments
                     allowFailure:(BOOL)allowFailure
                            error:(NSError **)error {
    NSTask *task = [NSTask new];
    task.executableURL = [NSURL fileURLWithPath:@"/bin/launchctl"];
    task.arguments = arguments;

    NSPipe *errorPipe = [NSPipe pipe];
    task.standardError = errorPipe;

    @try {
        [task launch];
        [task waitUntilExit];
    } @catch (NSException *exception) {
        if (allowFailure) {
            return YES;
        }
        if (error != nil) {
            *error = [self errorWithMessage:exception.reason ?: @"Could not run launchctl."];
        }
        return NO;
    }

    if (task.terminationStatus == 0 || allowFailure) {
        return YES;
    }

    NSData *errorData = [errorPipe.fileHandleForReading readDataToEndOfFile];
    NSString *errorText = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    if (error != nil) {
        *error = [self errorWithMessage:errorText.length > 0 ? errorText : @"launchctl failed."];
    }
    return NO;
}

- (NSString *)userDomain {
    return [NSString stringWithFormat:@"gui/%u", getuid()];
}

- (NSURL *)launchAgentPlistURL {
    NSURL *libraryURL = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                               inDomains:NSUserDomainMask].firstObject;
    return [[libraryURL URLByAppendingPathComponent:@"LaunchAgents" isDirectory:YES]
        URLByAppendingPathComponent:[LaunchAgentIdentifier stringByAppendingString:@".plist"]];
}

- (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"local.codex.dummy-display"
                               code:3
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
