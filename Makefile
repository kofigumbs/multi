SHELL = /bin/bash

SWIFT_CONFIGURATION := debug
SWIFT_BUILD_PATH = .build/apple/Products/$(SWIFT_CONFIGURATION)

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
	# local repo: /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask
	# example PR: https://github.com/Homebrew/homebrew-cask/pull/104655
	brew bump-cask-pr --no-fork --version `grep CFBundleVersion Multi.app/Contents/Info.plist | grep -o '\d\.\d\.\d'` multi
