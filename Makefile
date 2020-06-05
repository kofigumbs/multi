SHELL = /bin/bash

SWIFT_CONFIGURATION := debug
SWIFT_BUILD_PATH = .build/x86_64-apple-macosx/$(SWIFT_CONFIGURATION)

# <https://github.com/SlayterDev/RadiumBrowser>
DOWNLOAD_BLOCKLIST = curl -s https://raw.githubusercontent.com/SlayterDev/RadiumBrowser/master/RadiumBrowser

.PHONY: Multi.app
Multi.app: Multi.app/Preferences Multi.app/Contents/Resources/Stub Multi.app/Contents/Resources/Runtime Multi.app/Contents/Resources/blocklist.json

Multi.app/Preferences: $(SWIFT_BUILD_PATH)/Preferences
	cp $^ $@
Multi.app/Contents/Resources/Stub: $(SWIFT_BUILD_PATH)/Stub
	cp $^ $@
Multi.app/Contents/Resources/Runtime: $(SWIFT_BUILD_PATH)/Runtime
	cp $^ $@

$(SWIFT_BUILD_PATH)/%: Sources/%/*.swift Sources/Shared/*.swift
	swift build --product $*

Multi.app/Contents/Resources/blocklist.json:
	jq -cs 'reduce .[] as $$x ([]; . + $$x)' \
		<($(DOWNLOAD_BLOCKLIST)/adServerHosts.json)   \
		<($(DOWNLOAD_BLOCKLIST)/adaway.json)          \
		<($(DOWNLOAD_BLOCKLIST)/blackHosts.json)      \
		<($(DOWNLOAD_BLOCKLIST)/camelon.json)         \
		<($(DOWNLOAD_BLOCKLIST)/malwareHosts.json)    \
		<($(DOWNLOAD_BLOCKLIST)/simpleAds.json)       \
		<($(DOWNLOAD_BLOCKLIST)/tracker.json)         \
		<($(DOWNLOAD_BLOCKLIST)/ultimateAdBlock.json) \
		<($(DOWNLOAD_BLOCKLIST)/zeus.json)            \
		> $@
