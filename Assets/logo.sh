#!/usr/bin/env bash

set -eo pipefail

open "https://kofi.sexy/svg?q=%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2012%2012%22%3E%0A%20%20%3Cstyle%3E%0A%20%20%20%20*%20%7B%20font-family%3A%20%27BlinkMacSystemFont%27%3B%20font-weight%3A%20800%3B%20%7D%0A%20%20%3C%2Fstyle%3E%0A%20%20%3Crect%20x%3D%2210%25%22%20y%3D%2210%25%22%20width%3D%2280%25%22%20height%3D%2280%25%22%20fill%3D%22%23666%22%20rx%3D%221%22%20ry%3D%221%22%3E%3C%2Frect%3E%0A%20%20%3Ctext%20x%3D%226%22%20y%3D%226%22%20font-size%3D%223.5%22%20fill%3D%22white%22%20alignment-baseline%3D%22middle%22%20text-anchor%3D%22middle%22%3EMulti%3C%2Ftext%3E%0A%3C%2Fsvg%3E"
read -p "Click \"Download\" then enter the downloaded file path: " SVG_PATH

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --screenshot --window-size=1024,1024 --default-background-color=0 \
  "$SVG_PATH"

mv screenshot.png Assets/logo.png

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
