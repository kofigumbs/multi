#!/usr/bin/env bash

set -eo pipefail

ICON_TMP_DIR="`mktemp -d`/Icon.iconset"
mkdir "$ICON_TMP_DIR"
sips -z 16   16   Assets/logo.png --out "$ICON_TMP_DIR/icon_16x16.png"      > /dev/null
sips -z 32   32   Assets/logo.png --out "$ICON_TMP_DIR/icon_16x16@2x.png"   > /dev/null
sips -z 32   32   Assets/logo.png --out "$ICON_TMP_DIR/icon_32x32.png"      > /dev/null
sips -z 64   64   Assets/logo.png --out "$ICON_TMP_DIR/icon_32x32@2x.png"   > /dev/null
sips -z 128  128  Assets/logo.png --out "$ICON_TMP_DIR/icon_128x128.png"    > /dev/null
sips -z 256  256  Assets/logo.png --out "$ICON_TMP_DIR/icon_128x128@2x.png" > /dev/null
sips -z 256  256  Assets/logo.png --out "$ICON_TMP_DIR/icon_256x256.png"    > /dev/null
sips -z 512  512  Assets/logo.png --out "$ICON_TMP_DIR/icon_256x256@2x.png" > /dev/null
sips -z 512  512  Assets/logo.png --out "$ICON_TMP_DIR/icon_512x512.png"    > /dev/null
sips -z 1024 1024 Assets/logo.png --out "$ICON_TMP_DIR/icon_512x512@2x.png" > /dev/null
iconutil -c icns --output Multi.app/Contents/Resources/Icon.icns "$ICON_TMP_DIR"
