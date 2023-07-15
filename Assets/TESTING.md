```bash
MULTI_APP_NAME='Test' MULTI_JSON_CONFIG='{
  "windowed": true,
  "openNewWindowsWith": "com.mozilla.firefox",
  "openNewWindowsInBackground": true,
  "tabs": [
    { "title": "Alert", "url": "https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_alert" },
    { "title": "Confirm", "url": "https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_confirm" },
    { "title": "Prompt", "url": "https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_prompt" },
    { "title": "File", "url": "https://www.w3schools.com/tags/tryit.asp?filename=tryhtml5_input_type_file" },
    { "title": "External Links", "url": "https://www.w3schools.com/tags/tryit.asp?filename=tryhtml_a_target" },
    { "title": "Notifications", "url": "https://www.bennish.net/web-notifications.html" },
    { "title": "Popup", "url": "https://javascript.info/popup-windows#example-a-minimalistic-window" },
    { "title": "Basic Auth", "basicAuthUser": "guest", "basicAuthPassword": "guest", "url": "https://jigsaw.w3.org/HTTP/Basic/" }
  ]
}' ./Multi.app/Contents/Resources/create-mac-app
open ./Multi/Test.app
```
