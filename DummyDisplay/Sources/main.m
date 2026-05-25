#import <AppKit/AppKit.h>
#import "AppDelegate.h"
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
            if (strcmp(argv[index], "--smoke-test") == 0) {
                return runSmokeTest();
            }
        }

        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        return NSApplicationMain(argc, argv);
    }
}
