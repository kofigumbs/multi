# Multi

<a href="https://www.producthunt.com/posts/multi-3?utm_source=badge-featured&utm_medium=badge&utm_souce=badge-multi-3" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=229000&theme=dark" alt="Multi - Create a custom macOS app from a group of websites | Product Hunt Embed" style="width: 250px; height: 54px;" width="250px" height="54px" /></a>

Create a custom, lightweight macOS app from a group of websites.
Watch me create a Slack clone from scratch in 30 seconds (click the GIF for a higher resolution video):

<p align="center">
  <a href="https://kofi.sexy/slack-app-fewer-resources/demo.mp4" target="_blank">
    <img src="/Assets/demo.gif" alt="Demo GIF">
  </a>
</p>

 - Create apps from a UI or the command line
 - Configure settings with JSON
 - Built-in ad-blocker, provided by <https://better.fyi> (macOS 10.13+)
 - View one tab at a time or all at once with side-by-side view
 - Inject custom CSS to any site
 - Native bridges for Web APIs
     - `window.Notification`
     - `window.alert`
     - `window.confirm`
     - `window.prompt`
     - `<input type="file">`

## Installation

Download the latest `.dmg` file from the [releases](https://github.com/hkgumbs/multi/releases) page.

> **Note:** Multi 2.0.0 is a complete rewrite and works differently from previous versions.
> Any older Multi apps on your computer will continue but will lack the new features listed above.

> **Note:** Multi is not notarized, so you'll need to allow it to run via your "Security & Privacy" system preferences.
> See [Licensing](#licensing) for more about sponsoring Multi's development.


## JSON configuration

Multi apps store their configuration in a single JSON file.
If your app is named `Test`, then you'll find that file at `/Applications/Multi/Test.app/Contents/Resources/config.json`.
The JSON configuration allows 3 top-level fields:

| Field Name           | Type                                | Description                                                    |
|----------------------|-------------------------------------|----------------------------------------------------------------|
| `tabs`               | Array (Required)                    | Titles and URLs of tabs for this app                           |
| `sideBySide`         | Boolean (Optional, default `false`) | Show each tab simultaneously in one row                        |
| `alwaysNotify`       | Boolean (Optional, default `false`) | Show macOS notifications even if your app is currently focused |
| `openNewWindowsWith` | String (Optional, macOS 10.15+)     | Override system default browser for external links — value is a _bundle identifer_ like `com.apple.Safari`, `com.google.Chrome`, or `com.mozilla.firefox` |

The `tabs` field is an array of objects with the following fields:

| Field Name  | Type                        | Description                                                                      |
|-------------|-----------------------------|----------------------------------------------------------------------------------|
| `title`     | String (Required)           | Whatever you want to call this tab                                               |
| `url`       | String (Required)           | Starting page for this tab                                                       |
| `customCss` | Array of Strings (Optional) | Custom CSS URLs (see [Documentation/CUSTOM-CSS.md](Documentation/CUSTOM-CSS.md)) |

Here's the bare minimum example used in the Slack demo video above:

```json
{ "tabs": [{ "title": "Slack Lite", "url": "https://app.slack.com/client" }] }
```

Here's a fancier example that uses the optional fields referenced above:

```json
{
  "tabs": [
    {
      "title": "Dancing",
      "url": "https://rc.kofi.sexy/bathroom-floss"
    },
    {
      "title": "Walking",
      "url": "https://kofi.sexy/cel-shading",
      "customCss": [ "https://raw.githubusercontent.com/hkgumbs/multi/2.x/Assets/test.css" ]
    }
  ],
  "sideBySide": true,
  "alwaysNotify": true,
  "openNewWindowsWith": "com.apple.Safari"
}
```

If your configuration file fails to decode for any reason, your Multi app will open to the preferences window, where you can fix any issues.


## Using the CLI: `create-mac-app`

You can create and update Multi apps entirely from the command-line with the included script.
In fact, the Multi configuration UI just runs this script under-the-hood!
The `create-mac-app` script takes its options as environment variables.
For instance, here's how you'd create a bare-minimum app named `Test`:

```
MULTI_APP_NAME='Test' /Applications/Multi.app/Contents/Resources/create-mac-app
```

When you open `Test`, you'll be greeted with the preferences window, where you can finish configuring your app.
If you'd like to configure your app entirely from the command-line, you can set any of the following variables:

|                     |                                                                |
|---------------------|----------------------------------------------------------------|
| `MULTI_ICON_PATH`   | PNG or ICNS path to icon image                                 |
| `MULTI_JSON_CONFIG` | See [JSON configuration](#json-configuration)                  |
| `MULTI_OVERWRITE`   | Set to `1` to replace an existing Multi app with the same name |


## Keyboard shortcuts

Multi's shortcuts should work equivalently to those in modern browsers.

|      |            |   |                |                     |
|------|------------|---|----------------|---------------------|
| `⌘X` | Cut        |   | `⌘[`           | Back                |
| `⌘C` | Copy       |   | `⌘]`           | Forward             |
| `⌘V` | Paste      |   | `⌘R`           | Reload This Page    |
| `⌘A` | Select All |   | `⌘+`/`⌘-`/`⌘0` | Zoom in/out/default |
| `⌘M` | Minimize   |   | `^Tab`         | Select Next Tab     |
| `⌘H` | Hide       |   | `^↑Tab`        | Select Previous Tab |
| `⌘Q` | Quit       |   | `⌘1` - `⌘9`    | Select Tab          |
|      |            |   | `⌘L`           | Copy current URL    |

## Licensing

Multi is open source software (GPLv3), but it is also paid software.
One week after you first try Multi, you'll see a message in your apps asking you to
[purchase a license](https://gumbs.llc/multi/).
Since Multi is open source, and since I've made no attempt to obfuscate the code, you _could_ remove the license check and recompile the project.
Please don't do that.
I'd like to continue improving Multi with new features and bug fixes, and license purchases enable me to do so.
