SHELL=/bin/bash

GITHUB_USER:=kofigumbs
SWIFT_CONFIGURATION:=debug
SWIFT_BUILD_PATH=.build/apple/Products/$(SWIFT_CONFIGURATION)
VERSION=$(shell grep CFBundleVersion Multi.app/Contents/Info.plist | grep -o '\d\.\d\.\d')

.PHONY: Multi.app
Multi.app: Multi.app/Contents/MacOS Multi.app/Contents/MacOS/Preferences Multi.app/Contents/Resources/Runtime Multi.app/Contents/Resources/blocklist.json

Multi.app/Contents/MacOS:
	mkdir $@
Multi.app/Contents/MacOS/Preferences: $(SWIFT_BUILD_PATH)/Preferences
	cp $^ $@
Multi.app/Contents/Resources/Runtime: $(SWIFT_BUILD_PATH)/Runtime
	cp $^ $@

$(SWIFT_BUILD_PATH)/%: Sources/%/*.swift Sources/Shared/*.swift
	swift build --arch arm64 --arch x86_64 --configuration $(SWIFT_CONFIGURATION) --product $*

Multi.app/Contents/Resources/blocklist.json:
	curl https://better.fyi/blockerList.json > $@

.PHONY: release
release:
	swift package clean
	make SWIFT_CONFIGURATION=release Multi.app
	# http://www.zarkonnen.com/signing_notarizing_catalina
	codesign --sign "$$APPLE_DEVELOPER_SIGNING_IDENTITY" --timestamp --options runtime Multi.app/Contents/Resources/Runtime
	codesign --sign "$$APPLE_DEVELOPER_SIGNING_IDENTITY" --timestamp --options runtime Multi.app/Contents/MacOS/Preferences
	npx create-dmg --identity "$$APPLE_DEVELOPER_SIGNING_IDENTITY" Multi.app .build/
	xcrun altool --notarize-app --primary-bundle-id "llc.gumbs.multi" -u "$$APPLE_DEVELOPER_ID" -p "$$APPLE_DEVELOPER_PASSWORD" --file .build/Multi*.dmg
	@read -p "Wait for notarization, then press Enter to continue..."
	xcrun stapler staple .build/Multi*.dmg

.PHONY: cask
cask:
	brew bump-cask-pr --no-fork --write-only --commit --version ${VERSION} multi
	git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask push ${GITHUB_USER} HEAD:bump-multi-${VERSION}
	git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask reset --hard origin/HEAD
	open 'https://github.com/Homebrew/homebrew-cask/compare/master...kofigumbs:homebrew-cask:bump-multi-${VERSION}?body=Created with `brew bump-cask-pr`'
