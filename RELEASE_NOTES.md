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
