SHELL=/bin/bash

SWIFT_ARCH:=
SWIFT_CONFIGURATION:=debug
SWIFT_BUILD_PATH:=.build/debug
VERSION=$(shell plutil -extract CFBundleVersion raw Multi.app/Contents/Info.plist)

.PHONY: default
default:
	swift build $(SWIFT_ARCH) --configuration $(SWIFT_CONFIGURATION)
	mkdir -p Multi.app/Contents/Frameworks Multi.app/Contents/MacOS
	cp $(SWIFT_BUILD_PATH)/libRuntime.dylib Multi.app/Contents/Frameworks/
	cp $(SWIFT_BUILD_PATH)/{Stub,App} Multi.app/Contents/MacOS/

.PHONY: release
release:
	swift package clean
	make SWIFT_ARCH='--arch arm64 --arch x86_64' SWIFT_CONFIGURATION=release SWIFT_BUILD_PATH=.build/apple/Products/release
	codesign --sign "$$APPLE_DEVELOPER_SIGNING_IDENTITY" --timestamp --options runtime Multi.app/Contents/{Frameworks/libRuntime.dylib,MacOS/Stub,MacOS/App}
	npx create-dmg --identity "$$APPLE_DEVELOPER_SIGNING_IDENTITY" Multi.app .build/
	xcrun notarytool submit .build/Multi*.dmg --wait --team-id "$$APPLE_TEAM_ID" --apple-id "$$APPLE_DEVELOPER_ID" --password "$$APPLE_DEVELOPER_PASSWORD"
	xcrun stapler staple .build/Multi*.dmg

.PHONY: cask
cask:
	brew bump-cask-pr --version ${VERSION} multi
