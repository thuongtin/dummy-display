#import "AppDelegate.h"
#import "AppPreferences.h"
#import "LoginItemController.h"
#import "VirtualDisplayController.h"

@interface AppDelegate ()
@property(nonatomic, strong) NSStatusItem *statusItem;
@property(nonatomic, strong) NSMenu *statusMenu;
@property(nonatomic, strong) VirtualDisplayController *displayController;
@property(nonatomic, strong) AppPreferences *preferences;
@property(nonatomic, strong) NSMenuItem *statusMenuItem;
@property(nonatomic, strong) NSMenuItem *startMenuItem;
@property(nonatomic, strong) NSMenuItem *stopMenuItem;
@property(nonatomic, strong) NSMenuItem *hiDPIMenuItem;
@property(nonatomic, strong) NSMenuItem *loginItemMenuItem;
@property(nonatomic, strong) NSMenuItem *autoStartMenuItem;
@property(nonatomic, strong) NSArray<NSMenuItem *> *presetMenuItems;
@property(nonatomic, strong) LoginItemController *loginItemController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;

    self.displayController = [VirtualDisplayController new];
    self.loginItemController = [LoginItemController new];
    self.preferences = [[AppPreferences alloc] initWithDefaults:NSUserDefaults.standardUserDefaults];

    [self buildMenuBarItem];
    [self updateMenu];
    [self autoStartDisplayIfNeeded];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    (void)notification;
    [self.displayController stop];
}

- (void)buildMenuBarItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.title = @"DD";
    self.statusItem.button.toolTip = @"Dummy Display";

    if (@available(macOS 11.0, *)) {
        NSImage *image = [NSImage imageWithSystemSymbolName:@"display" accessibilityDescription:@"Dummy Display"];
        self.statusItem.button.image = image;
        self.statusItem.button.title = @"";
    }

    self.statusMenu = [NSMenu new];
    self.statusMenu.autoenablesItems = NO;

    self.statusMenuItem = [[NSMenuItem alloc] initWithTitle:@"Idle" action:nil keyEquivalent:@""];
    self.statusMenuItem.enabled = NO;
    [self.statusMenu addItem:self.statusMenuItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];

    NSMutableArray<NSMenuItem *> *presetItems = [NSMutableArray array];
    NSArray<NSString *> *titles = [VirtualDisplayController presetTitles];
    for (NSInteger index = 0; index < titles.count; index++) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:titles[index]
                                                      action:@selector(selectPreset:)
                                               keyEquivalent:@""];
        item.target = self;
        item.tag = index;
        [presetItems addObject:item];
        [self.statusMenu addItem:item];
    }
    self.presetMenuItems = presetItems;

    [self.statusMenu addItem:[NSMenuItem separatorItem]];

    self.hiDPIMenuItem = [[NSMenuItem alloc] initWithTitle:@"HiDPI"
                                                    action:@selector(toggleHiDPI:)
                                             keyEquivalent:@""];
    self.hiDPIMenuItem.target = self;
    [self.statusMenu addItem:self.hiDPIMenuItem];

    self.autoStartMenuItem = [[NSMenuItem alloc] initWithTitle:@"Auto Start Display"
                                                        action:@selector(toggleAutoStart:)
                                                 keyEquivalent:@""];
    self.autoStartMenuItem.target = self;
    [self.statusMenu addItem:self.autoStartMenuItem];

    self.loginItemMenuItem = [[NSMenuItem alloc] initWithTitle:@"Launch at Login"
                                                        action:@selector(toggleLaunchAtLogin:)
                                                 keyEquivalent:@""];
    self.loginItemMenuItem.target = self;
    [self.statusMenu addItem:self.loginItemMenuItem];

    [self.statusMenu addItem:[NSMenuItem separatorItem]];

    self.startMenuItem = [[NSMenuItem alloc] initWithTitle:@"Start"
                                                    action:@selector(startDisplay:)
                                             keyEquivalent:@""];
    self.startMenuItem.target = self;
    [self.statusMenu addItem:self.startMenuItem];

    self.stopMenuItem = [[NSMenuItem alloc] initWithTitle:@"Stop"
                                                   action:@selector(stopDisplay:)
                                            keyEquivalent:@""];
    self.stopMenuItem.target = self;
    [self.statusMenu addItem:self.stopMenuItem];

    [self.statusMenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                                      action:@selector(terminate:)
                                               keyEquivalent:@"q"];
    quitItem.target = NSApp;
    [self.statusMenu addItem:quitItem];

    self.statusItem.menu = self.statusMenu;
}

- (void)selectPreset:(NSMenuItem *)sender {
    self.preferences.selectedPreset = (DummyDisplayPreset)sender.tag;
    [self.preferences save];
    [self updateMenu];
}

- (void)toggleHiDPI:(id)sender {
    (void)sender;
    self.preferences.hiDPIEnabled = !self.preferences.hiDPIEnabled;
    [self.preferences save];
    [self updateMenu];
}

- (void)toggleAutoStart:(id)sender {
    (void)sender;
    self.preferences.autoStartEnabled = !self.preferences.autoStartEnabled;
    [self.preferences save];
    [self updateMenu];
}

- (void)toggleLaunchAtLogin:(id)sender {
    (void)sender;

    NSError *error = nil;
    BOOL targetState = !self.loginItemController.isEnabled;
    BOOL ok = [self.loginItemController setEnabled:targetState error:&error];
    if (!ok) {
        [self showError:error.localizedDescription];
    }
    [self updateMenu];
}

- (void)startDisplay:(id)sender {
    (void)sender;

    NSError *error = nil;
    BOOL ok = [self.displayController startWithPreset:self.preferences.selectedPreset
                                                hiDPI:self.preferences.hiDPIEnabled
                                                error:&error];
    if (!ok) {
        [self showError:error.localizedDescription];
    }
    [self updateMenu];
}

- (void)stopDisplay:(id)sender {
    (void)sender;
    [self.displayController stop];
    [self updateMenu];
}

- (void)updateMenu {
    BOOL active = self.displayController.isActive;
    self.statusMenuItem.title = self.displayController.statusText;
    self.startMenuItem.enabled = !active;
    self.stopMenuItem.enabled = active;
    self.hiDPIMenuItem.enabled = !active;
    self.hiDPIMenuItem.state = self.preferences.hiDPIEnabled ? NSControlStateValueOn : NSControlStateValueOff;
    self.autoStartMenuItem.state = self.preferences.autoStartEnabled ? NSControlStateValueOn : NSControlStateValueOff;
    self.loginItemMenuItem.title = self.loginItemController.statusText;
    self.loginItemMenuItem.state = self.loginItemController.isEnabled ? NSControlStateValueOn : NSControlStateValueOff;

    for (NSMenuItem *item in self.presetMenuItems) {
        item.enabled = !active;
        item.state = item.tag == self.preferences.selectedPreset ? NSControlStateValueOn : NSControlStateValueOff;
    }

    if (@available(macOS 11.0, *)) {
        self.statusItem.button.contentTintColor = active ? NSColor.systemGreenColor : nil;
    } else {
        self.statusItem.button.title = active ? @"DD*" : @"DD";
    }
}

- (void)autoStartDisplayIfNeeded {
    if (!self.preferences.autoStartEnabled || self.displayController.isActive) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.displayController.isActive) {
            return;
        }

        NSError *error = nil;
        BOOL ok = [self.displayController startWithPreset:self.preferences.selectedPreset
                                                    hiDPI:self.preferences.hiDPIEnabled
                                                    error:&error];
        if (!ok) {
            [self showError:error.localizedDescription];
        }
        [self updateMenu];
    });
}

- (void)showError:(NSString *)message {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"Could not start display";
    alert.informativeText = message ?: @"Unknown error";
    alert.alertStyle = NSAlertStyleWarning;
    [alert runModal];
}

@end
