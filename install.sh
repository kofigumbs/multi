#!/usr/bin/env bash

set -e

name="Chat"
icon="Icon.png"

rm -rf "${name}.app" "Icon.iconset"

swift build
cp -r "{{TEMPLATE}}.app" "${name}.app"
cp .build/x86*/debug/Multi "${name}.app"
sed -i '' "s/{{TEMPLATE}}/${name}/g" "${name}.app/Contents/Info.plist"

mkdir Icon.iconset
sips -z 16 16     ${icon} --out "Icon.iconset/icon_16x16.png"      > /dev/null
sips -z 32 32     ${icon} --out "Icon.iconset/icon_16x16@2x.png"   > /dev/null
sips -z 32 32     ${icon} --out "Icon.iconset/icon_32x32.png"      > /dev/null
sips -z 64 64     ${icon} --out "Icon.iconset/icon_32x32@2x.png"   > /dev/null
sips -z 128 128   ${icon} --out "Icon.iconset/icon_128x128.png"    > /dev/null
sips -z 256 256   ${icon} --out "Icon.iconset/icon_128x128@2x.png" > /dev/null
sips -z 256 256   ${icon} --out "Icon.iconset/icon_256x256.png"    > /dev/null
sips -z 512 512   ${icon} --out "Icon.iconset/icon_256x256@2x.png" > /dev/null
sips -z 512 512   ${icon} --out "Icon.iconset/icon_512x512.png"    > /dev/null
sips -z 1024 1024 ${icon} --out "Icon.iconset/icon_512x512@2x.png" > /dev/null
iconutil -c icns --output "${name}.app/Contents/Resources/Icon.icns" "Icon.iconset"
