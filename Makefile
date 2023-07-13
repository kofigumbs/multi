SHELL=/bin/bash

GITHUB_USER:=kofigumbs
SWIFT_ARCH:=
SWIFT_CONFIGURATION:=debug
SWIFT_BUILD_PATH:=.build/debug
VERSION=$(shell plutil -extract CFBundleVersion raw Multi.app/Contents/Info.plist )

.PHONY: Multi.app
Multi.app: Multi.app/Contents/MacOS Multi.app/Contents/MacOS/App Multi.app/Contents/Resources/Runtime

Multi.app/Contents/MacOS:
	mkdir $@
Multi.app/Contents/MacOS/App: $(SWIFT_BUILD_PATH)/App
	cp $^ $@
Multi.app/Contents/Resources/Runtime: $(SWIFT_BUILD_PATH)/Runtime
	cp $^ $@

$(SWIFT_BUILD_PATH)/%: Sources/Multi%/*.swift Sources/MultiSettings/*.swift
	swift build $(SWIFT_ARCH) --configuration $(SWIFT_CONFIGURATION) --product $*

.PHONY: release
release:
	swift package clean
	make SWIFT_ARCH='--arch arm64 --arch x86_64' SWIFT_CONFIGURATION=release SWIFT_BUILD_PATH=.build/apple/Products/release Multi.app
	# http://www.zarkonnen.com/signing_notarizing_catalina
	codesign --sign "$$APPLE_DEVELOPER_SIGNING_IDENTITY" --timestamp --options runtime Multi.app/Contents/Resources/Runtime
	codesign --sign "$$APPLE_DEVELOPER_SIGNING_IDENTITY" --timestamp --options runtime Multi.app/Contents/MacOS/App
	npx create-dmg --identity "$$APPLE_DEVELOPER_SIGNING_IDENTITY" Multi.app .build/
	xcrun notarytool submit .build/Multi*.dmg --wait --team-id "$$APPLE_TEAM_ID" --apple-id "$$APPLE_DEVELOPER_ID" --password "$$APPLE_DEVELOPER_PASSWORD"
	xcrun stapler staple .build/Multi*.dmg

.PHONY: cask
cask:
	brew bump-cask-pr --no-fork --write-only --commit --version ${VERSION} multi
	git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask push ${GITHUB_USER} HEAD:bump-multi-${VERSION}
	git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask reset --hard origin/HEAD
	open 'https://github.com/Homebrew/homebrew-cask/compare/master...kofigumbs:homebrew-cask:bump-multi-${VERSION}?body=Created with `brew bump-cask-pr`'
