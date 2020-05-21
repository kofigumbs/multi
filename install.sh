#!/usr/bin/env bash

set -e

icon="icon.png"
name="Chat"
contents="${name}.app/Contents"

rm -rf "${name}.app" "${name}.iconset"
mkdir -p "${contents}/MacOS" "${contents}/Resources"
cp "main" "${name}.app/${name}"
cp "config.json" "${contents}/Resources"

mkdir ${name}.iconset
sips -z 16 16     ${icon} --out "${name}.iconset/icon_16x16.png"      > /dev/null
sips -z 32 32     ${icon} --out "${name}.iconset/icon_16x16@2x.png"   > /dev/null
sips -z 32 32     ${icon} --out "${name}.iconset/icon_32x32.png"      > /dev/null
sips -z 64 64     ${icon} --out "${name}.iconset/icon_32x32@2x.png"   > /dev/null
sips -z 128 128   ${icon} --out "${name}.iconset/icon_128x128.png"    > /dev/null
sips -z 256 256   ${icon} --out "${name}.iconset/icon_128x128@2x.png" > /dev/null
sips -z 256 256   ${icon} --out "${name}.iconset/icon_256x256.png"    > /dev/null
sips -z 512 512   ${icon} --out "${name}.iconset/icon_256x256@2x.png" > /dev/null
sips -z 512 512   ${icon} --out "${name}.iconset/icon_512x512.png"    > /dev/null
sips -z 1024 1024 ${icon} --out "${name}.iconset/icon_512x512@2x.png" > /dev/null
iconutil -c icns "${name}.iconset"
mv "${name}.icns" "${name}.app/Contents/Resources"

cat <<EOF > "${name}.app/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundlePackageType</key><string>APPL</string><key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleIconFile</key>           <string>${name}.icns</string>
    <key>CFBundleName</key>               <string>${name}</string>
    <key>CFBundleExecutable</key>         <string>${name}</string>
    <key>CFBundleIdentifier</key>         <string>main.bundle.id.shim</string>
    <key>CFBundleVersion</key>            <string>0.1.1</string>
    <key>CFBundleGetInfoString</key>      <string>0.1</string>
    <key>CFBundleShortVersionString</key> <string>0.1</string>
    <key>NSPrincipalClass</key>           <string>NSApplication</string>
    <key>NSMainNibFile</key>              <string>MainMenu</string>
</dict></plist>
EOF
