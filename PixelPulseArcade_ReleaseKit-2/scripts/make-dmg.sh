#!/bin/bash
set -euo pipefail

APP="build/Build/Products/Release/PixelPulse Arcade.app"
ROOT="dmg-root"
OUT="dist/PixelPulse-Arcade-macOS.dmg"

rm -rf "$ROOT" dist
mkdir -p "$ROOT" dist

if [ ! -d "$APP" ]; then
  echo "App not found: $APP"
  exit 1
fi

ditto "$APP" "$ROOT/PixelPulse Arcade.app"
ln -s /Applications "$ROOT/Applications"

hdiutil create \
  -volname "PixelPulse Arcade" \
  -srcfolder "$ROOT" \
  -format UDZO \
  -ov \
  "$OUT"

echo "Created $OUT"
