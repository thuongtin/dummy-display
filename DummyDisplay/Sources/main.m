#import <AppKit/AppKit.h>
#import "AppDelegate.h"
#import "AppPreferences.h"
#import "LoginItemController.h"
#import "VirtualDisplayController.h"

static uint32_t activeDisplayCount(void) {
    uint32_t count = 0;
    CGGetActiveDisplayList(0, NULL, &count);
    return count;
}

static int runSmokeTest(void) {
    @autoreleasepool {
        uint32_t before = activeDisplayCount();

        VirtualDisplayController *controller = [VirtualDisplayController new];
        NSError *error = nil;
        BOOL started = [controller startWithPreset:DummyDisplayPreset1440p hiDPI:YES error:&error];
        uint32_t during = activeDisplayCount();

        if (!started) {
            fprintf(stderr, "Smoke test failed to start display: %s\n", error.localizedDescription.UTF8String);
            return 2;
        }

        printf("before=%u during=%u displayID=%u\n", before, during, controller.displayID);
        [controller stop];
        sleep(1);

        uint32_t after = activeDisplayCount();
        printf("after=%u\n", after);

        if (during <= before || after != before) {
            fprintf(stderr, "Smoke test failed count check\n");
            return 3;
        }

        printf("Smoke test passed\n");
        return 0;
    }
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        for (int index = 1; index < argc; index++) {
            if (strcmp(argv[index], "--display-count") == 0) {
                printf("%u\n", activeDisplayCount());
                return 0;
            }
            if (strcmp(argv[index], "--smoke-test") == 0) {
                return runSmokeTest();
            }
            if (strcmp(argv[index], "--prefs-status") == 0) {
                AppPreferences *preferences = [[AppPreferences alloc] initWithDefaults:NSUserDefaults.standardUserDefaults];
                printf("%s\n", preferences.debugStatusText.UTF8String);
                return 0;
            }
            if (strcmp(argv[index], "--auto-start-enable") == 0 || strcmp(argv[index], "--auto-start-disable") == 0) {
                AppPreferences *preferences = [[AppPreferences alloc] initWithDefaults:NSUserDefaults.standardUserDefaults];
                preferences.autoStartEnabled = strcmp(argv[index], "--auto-start-enable") == 0;
                [preferences save];
                printf("%s\n", preferences.debugStatusText.UTF8String);
                return 0;
            }
            if (strcmp(argv[index], "--login-status") == 0) {
                LoginItemController *controller = [LoginItemController new];
                printf("%s\n", controller.debugStatusText.UTF8String);
                return 0;
            }
            if (strcmp(argv[index], "--login-enable") == 0 || strcmp(argv[index], "--login-disable") == 0) {
                LoginItemController *controller = [LoginItemController new];
                NSError *error = nil;
                BOOL enable = strcmp(argv[index], "--login-enable") == 0;
                BOOL ok = [controller setEnabled:enable error:&error];
                if (!ok) {
                    fprintf(stderr, "%s\n", error.localizedDescription.UTF8String);
                    return 4;
                }
                printf("%s\n", controller.debugStatusText.UTF8String);
                return 0;
            }
        }

        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        return NSApplicationMain(argc, argv);
    }
}
