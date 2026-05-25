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
