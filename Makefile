SWIFT_CONFIGURATION := debug
SWIFT_BUILD_PATH = .build/x86_64-apple-macosx/$(SWIFT_CONFIGURATION)

.PHONY: Multi.app
Multi.app: Multi.app/Builder Multi.app/Contents/Resources/Stub Multi.app/Contents/Resources/Runner

Multi.app/Builder: $(SWIFT_BUILD_PATH)/Builder
	cp $^ $@
Multi.app/Contents/Resources/Stub: $(SWIFT_BUILD_PATH)/Stub
	cp $^ $@
Multi.app/Contents/Resources/Runner: $(SWIFT_BUILD_PATH)/Runner
	cp $^ $@

$(SWIFT_BUILD_PATH)/%: Sources/%/*.swift
	swift build --product $*
