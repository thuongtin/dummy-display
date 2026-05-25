# Dummy Display Design

## Goal

Create a local macOS app that can add a real virtual display to the current Mac, replacing the need for an HDMI dummy plug.

## Chosen Approach

Use the private Objective-C CoreGraphics classes available on this Mac:

- `CGVirtualDisplayDescriptor`
- `CGVirtualDisplay`
- `CGVirtualDisplayMode`
- `CGVirtualDisplaySettings`

A runtime probe on macOS 26.5 created a display successfully. `CGGetActiveDisplayList` went from 4 displays to 5 after creation, then back to 4 after release.

## App Shape

The app is a small local AppKit menu bar utility:

- Menu bar status item.
- Menu item with current status.
- Resolution preset radio items.
- HiDPI toggle item.
- Launch at Login toggle item using `SMAppService.mainAppService`.
- Start menu item to create and retain the virtual display.
- Stop menu item to release it.

The app must keep a strong reference to `CGVirtualDisplay` while the dummy display is active. Releasing that object removes the display from the system.

## Tradeoffs

This uses private API. It is appropriate for a local personal tool, not for App Store distribution. It may break on future macOS versions. The implementation keeps private API usage in one controller so it is easy to replace if Apple exposes a public API later.

## Verification

Verification requires both build and runtime checks:

- Build the `.app` bundle.
- Launch it.
- Start the dummy display.
- Confirm `CGGetActiveDisplayList` count increases.
- Stop the dummy display.
- Confirm the display count returns to the original value.
