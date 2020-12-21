# Custom JS

Multi lets you add custom JS (a.k.a. script injection) to any site in your Multi App.
The custom JS is applied after each page in that tab is loaded.
Each custom JS rule is specified with a URL, which gives you a few options for how you want to manage your scripts:

1. Put your script online, and use their URL: ex. `https://raw.githubusercontent.com/kofigumbs/multi/2.x/Assets/test.js`
2. Put your script in a file on your computer, and reference them locally: ex. `file:///Users/kofi/Documents/multi/Assets/test.js`
3. Encode your script directly in the Multi settings using [Data URIs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs): ex. `data:,console.log%28%27Hello%2C%20from%20Multi%21%27%29%3B%0A`

## Examples

- [Drag & Drop to open URLs](https://gist.github.com/kofigumbs/37c4dd92fade342be705245f39310a46)
- [Find in page](https://gist.github.com/kofigumbs/a966f381cd08ec27addf2b4e7e3246bc)
- [Fix links in GMail and Google Calendar](https://gist.github.com/kofigumbs/9a374fe1d99c57dd2f69dd17ede367a8)
- [Reload Slack when it disconnects](https://gist.github.com/kofigumbs/a77b981fb5f52e04581d96ea654fd7a5)

> **Share yours!**
> I'm actively looking for neat JS snippets to share here.
> Please open an Issue or Pull Request if you'd like to contribute.
