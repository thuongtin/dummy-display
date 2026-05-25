# Dummy Display

Dummy Display is a small macOS menu bar utility that creates a virtual display to replace an HDMI dummy plug.

It is useful when you need a headless, remote, or extra workspace display without plugging in a physical HDMI dummy adapter.

## Features

- Menu bar only, no Dock icon.
- Creates and removes a real virtual display.
- Resolution presets: `1920 x 1080`, `2560 x 1440`, `3840 x 2160`.
- HiDPI toggle.
- Launch at Login toggle.
- Generated app icon.

## Important Notes

This project uses private CoreGraphics Objective-C classes:

- `CGVirtualDisplayDescriptor`
- `CGVirtualDisplay`
- `CGVirtualDisplayMode`
- `CGVirtualDisplaySettings`

It is intended for local personal use and is not App Store suitable. These APIs may change in future macOS versions.

## Requirements

- macOS with `CGVirtualDisplay` runtime support. This was tested on macOS 26.5.
- Xcode Command Line Tools or Xcode.

## Build From Source

```bash
./scripts/build.sh
```

The app bundle is created at:

```text
build/Dummy Display.app
```

## Run Locally

```bash
open "build/Dummy Display.app"
```

Use the menu bar display icon to choose a preset, toggle HiDPI, start the virtual display, stop it, and enable launch at login.

The build script also generates the app icon at `DummyDisplay/Resources/AppIcon.icns`.

Launch at Login uses `SMAppService` when macOS accepts the app bundle. If macOS reports the app as not found, Dummy Display falls back to a per-user LaunchAgent in `~/Library/LaunchAgents`.

## Install A Release Build

Download `Dummy-Display.app.zip` from the GitHub release, unzip it, then move the app to `/Applications`.

If macOS blocks the app because it was downloaded from the internet, clear the quarantine attribute:

```bash
sudo xattr -cr "/Applications/Dummy Display.app"
```

Then open it:

```bash
open "/Applications/Dummy Display.app"
```

## Development

Run the runtime smoke test:

```bash
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --smoke-test
```

Expected result: the active display count increases by one, then returns to the original count.

Check launch-at-login diagnostics:

```bash
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --login-status
```

You can also verify the toggle path from CLI:

```bash
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --login-enable
"build/Dummy Display.app/Contents/MacOS/Dummy Display" --login-disable
```

## License

MIT
