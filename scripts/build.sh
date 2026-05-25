#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_NAME="Dummy Display"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

swift "$ROOT_DIR/scripts/generate_icon.swift"

clang \
  -fobjc-arc \
  "$ROOT_DIR/DummyDisplay/Sources/main.m" \
  "$ROOT_DIR/DummyDisplay/Sources/AppDelegate.m" \
  "$ROOT_DIR/DummyDisplay/Sources/AppPreferences.m" \
  "$ROOT_DIR/DummyDisplay/Sources/LoginItemController.m" \
  "$ROOT_DIR/DummyDisplay/Sources/VirtualDisplayController.m" \
  -framework AppKit \
  -framework Foundation \
  -framework CoreGraphics \
  -framework ServiceManagement \
  -o "$MACOS_DIR/Dummy Display"

cp "$ROOT_DIR/DummyDisplay/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/DummyDisplay/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
codesign --force --sign - "$APP_DIR" >/dev/null

echo "Built $APP_DIR"
