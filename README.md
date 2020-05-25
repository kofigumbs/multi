# Multi

- Build your own custom macOS apps with different webviews
- Switch between the tabs with ⌘ shortcuts
- Bridge web notifications to macOS Notification Center
- Native Cut/Copy/Paste/Quit controls

Read more about the motivation and process on my blog: <https://kofi.sexy/blog/multi>.


## Quick Start

```bash
./create-mac-app <YOUR_APP_NAME> <YOUR_ICON_PNG_PATH>
open <YOUR_APP_NAME>.app/Contents/Resources/config.json # edit your app's websites
open <YOUR_APP_NAME>.app # open and use your custom app
```

These instructions were developed and tested with Swift 4.2 on macOS 10.13 High Sierra.


## Common Issues

1. If you (1) have XCode installed and (2) see one of these errors when running `create-mac-app`:

   -
     ```
     error: terminated(72): xcrun --sdk macosx --find xctest output:
         xcrun: error: unable to find utility "xctest", not a developer tool or in PATH
     ```
   -
     ```
     dyld: Library not loaded: @rpath/llbuild.framework/Versions/A/llbuild
     Referenced from: /Library/Developer/CommandLineTools/usr/bin/swift-package 
         Reason: image not found
         Abort trap: 6
     ```

   Try this fix, which tells XCode Command Line Tools where to find the most up-to-date libraries:

   ```
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```

2. If you (1) use macOS 10.11 or 10.12 and (2) see the following error when running `create-mac-app`:

   ```
   Package.swift:12:5: error: argument 'targets' must precede argument 'dependencies'
       targets: [
       ^
   Can't parse Package.swift manifest file because it contains invalid format. Fix Package.swift file format and try again.
   ```

   You are probably using Swift 3.
   You can confirm that by running `swift --version`.
   Switching to the [`swift3` branch](https://github.com/hkgumbs/multi/tree/swift3) should probably get you up and running.

   ```
   git checkout swift3
   ```
