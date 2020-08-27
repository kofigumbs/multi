Scenarios listed in this document are manually verified before each release.
First, run the following to set everything back to normal.

```bash
defaults delete gumbs.llc
rm -rf /Applications/Multi.app
rm -rf /Applications/Multi/Test*
make
cp -r Multi.app /Applications/Multi.app
```

# Create new app from UI

```bash
open /Applications/Multi.app
```

Name the app "Test 1".

# Create new app from script

```bash
MULTI_APP_NAME='Test 2' \
  /Applications/Multi.app/Contents/Resources/create-mac-app
open /Applications/Multi/Test\ 2.app
```

# Update existing app

```bash
MULTI_APP_NAME='Test 2' \
  MULTI_ICON_PATH='Assets/test-icon.png' \
  MULTI_JSON_CONFIG='{"tabs":[{"title":"Example","url":"https://example.com"}]}' \
  MULTI_OVERWRITE=1 \
  /Applications/Multi.app/Contents/Resources/create-mac-app
open /Applications/Multi/Test\ 2.app
```

# License Key

```bash
defaults write gumbs.llc multi.first-launch -date "2020-01-01 00:00:00 +0000"
echo "$MULTI_LICENSE_KEY" | pbcopy
open /Applications/Multi/Test\ 2.app
```

Verify trial expiration page.
Save the license key via the UI.
App should no longer have trial expiration page.

# Side-by-side + Notifications + Alert + Confirm + File + Ad-blocker + Popup

```bash
MULTI_APP_NAME='Test 3' \
  MULTI_ICON_PATH='Assets/test-icon.icns' \
  MULTI_JSON_CONFIG='{"sideBySide":true,"tabs":[{"title":"Notifications","url":"https://www.bennish.net/web-notifications.html"},{"title":"Alert","url":"https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_alert"},{"title":"Confirm","url":"https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_confirm"},{"title":"File","url":"https://www.w3schools.com/tags/tryit.asp?filename=tryhtml5_input_type_file"},{"title":"Ads","url":"https://ads-blocker.com/testing/#ad-blocker-test-steps"},{"title":"Popup","url":"https://javascript.info/popup-windows#example-a-minimalistic-window"}]}' \
  /Applications/Multi.app/Contents/Resources/create-mac-app
open /Applications/Multi/Test\ 3.app
```

Verify ICNS icon.
Click button on each page to test the feature in question.

# Custom CSS

```bash
MULTI_APP_NAME='Test 4' \
  MULTI_JSON_CONFIG='{"tabs":[{"title":"Custom CSS","url":"https://kofi.sexy","customCss":["https://raw.githubusercontent.com/hkgumbs/multi/2.x/Assets/test.css","file:///Users/kofi/Documents/multi/Assets/test.css","body%20%7B%20background%3A%20mediumpurple%3B%20%7D"]}]}' \
  /Applications/Multi.app/Contents/Resources/create-mac-app
open /Applications/Multi/Test\ 4.app
```

Verify that the custom style rule exists 3 times.

# Keyboard shortcuts

```bash
MULTI_APP_NAME='Test 5' \
  MULTI_JSON_CONFIG='{"tabs":[{"title":"DuckDuckGo","url":"https://duckduckgo.com"},{"title":"Google","url":"https://google.com"}]}' \
  /Applications/Multi.app/Contents/Resources/create-mac-app
open /Applications/Multi/Test\ 5.app
```

- [ ] Cut
- [ ] Copy
- [ ] Paste
- [ ] Refresh
- [ ] Back
- [ ] Forward
- [ ] Hide
- [ ] Minimize
- [ ] Next Tab
- [ ] Previous Tab
- [ ] Tabs: 1, 2, etc.
- [ ] Copy URL
- [ ] Zoom in, zoom out, zoom actual (should persist restart)
