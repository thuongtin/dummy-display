# Dummy Display 0.1.2

Adds Auto Start Display on launch.

## Changes

- Adds an `Auto Start Display` menu item.
- Persists preset, HiDPI, and auto-start preferences with `NSUserDefaults`.
- Automatically creates the virtual display on app launch when auto-start is enabled.
- Adds CLI diagnostics and test hooks for preferences and display count.

## Verify Auto Start

```bash
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --auto-start-enable
open "build/Dummy Display.app"
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --display-count
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --auto-start-disable
```

# Dummy Display 0.1.1

Fixes Launch at Login when macOS reports `SMAppService.mainAppService` as `App Not Found`.

## Changes

- Falls back to a per-user LaunchAgent in `~/Library/LaunchAgents` when `SMAppService` returns `not-found`.
- Adds CLI diagnostics for launch-at-login state.
- Keeps `SMAppService` support for environments where macOS accepts the app bundle directly.

## Verify Launch at Login

```bash
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --login-status
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --login-enable
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --login-disable
```

If macOS blocks the downloaded app, run:

```bash
sudo xattr -cr "/Applications/Dummy Display.app"
```

# Dummy Display 0.1.0

Initial open-source release.

## Features

- Menu bar app for creating a virtual dummy display on macOS.
- Presets for 1080p, 1440p, and 4K.
- HiDPI toggle.
- Launch at Login toggle.
- Generated app icon.

## Notes

This app uses private CoreGraphics `CGVirtualDisplay` APIs. It is intended for local personal use and is not App Store suitable.

If macOS blocks the downloaded app, run:

```bash
sudo xattr -cr "/Applications/Dummy Display.app"
```
