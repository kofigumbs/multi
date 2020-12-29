Reset everything back to normal:

```bash
defaults delete gumbs.llc
defaults write gumbs.llc multi.first-launch -date "2020-01-01 00:00:00 +0000"
rm -rf /Applications/Multi.app
rm -rf /Applications/Multi/Test
make
cp -r Multi.app /Applications/Multi.app
```

Create the test app:

```bash
MULTI_APP_NAME='Test' \
  MULTI_JSON_CONFIG='{
    "windowed": true,
    "openNewWindowsWith": "com.apple.Safari",
    "openNewWindowsInBackground": true,
    "tabs": [
      { "title": "Alert", "url": "https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_alert" },
      { "title": "Confirm", "url": "https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_confirm" },
      { "title": "File", "url": "https://www.w3schools.com/tags/tryit.asp?filename=tryhtml5_input_type_file" },
      { "title": "External Links", "url": "https://www.w3schools.com/tags/tryit.asp?filename=tryhtml_a_target" },
      { "title": "Notifications", "url": "https://www.bennish.net/web-notifications.html" },
      { "title": "Ads", "url": "https://ads-blocker.com/testing/#ad-blocker-test-steps" },
      { "title": "Popup", "url": "https://javascript.info/popup-windows#example-a-minimalistic-window" },
      { "title": "Basic Auth", "basicAuthUser": "guest", "basicAuthPassword": "guest", "url": "https://jigsaw.w3.org/HTTP/Basic/" }
    ]
  }' \
  /Applications/Multi.app/Contents/Resources/create-mac-app
open /Applications/Multi/Test.app
```
