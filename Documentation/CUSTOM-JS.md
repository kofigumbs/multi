# Custom JS

Multi lets you add custom JS (a.k.a. script injection) to any site in your Multi App.
The custom JS is applied after each page in that tab is loaded.
Each custom JS rule is specified with a URL, which gives you a few options for how you want to manage your scripts:

1. Put your script online, and use their URL: ex. `https://raw.githubusercontent.com/kofigumbs/multi/2.x/Assets/test.js`
2. Put your script in a file on your computer, and reference them locally: ex. `file:///Users/kofi/Documents/multi/Assets/test.js`
3. Encode your script directly in the Multi settings using [Data URIs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs): ex. `data:,console.log%28%27Hello%2C%20from%20Multi%21%27%29%3B%0A`

## Examples

### Fix external links in GMail

*JS*
```js
(() => {
  const listener = e => e.stopPropagation();
  const query = () => document.querySelectorAll('a[target=_blank]').forEach(a => {
    a.removeEventListener('click', listener);
    a.addEventListener('click', listener, true);
  });
  query();
  window.addEventListener('hashchange', query);
})();
```

*JS Data URI*
```
data:,%28%28%29%20%3D%3E%20%7B%0A%20%20const%20listener%20%3D%20e%20%3D%3E%20e.stopPropagation%28%29%3B%0A%20%20const%20query%20%3D%20%28%29%20%3D%3E%20document.querySelectorAll%28%27a%5Btarget%3D_blank%5D%27%29.forEach%28a%20%3D%3E%20%7B%0A%20%20%20%20a.removeEventListener%28%27click%27%2C%20listener%29%3B%0A%20%20%20%20a.addEventListener%28%27click%27%2C%20listener%2C%20true%29%3B%0A%20%20%7D%29%3B%0A%20%20query%28%29%3B%0A%20%20window.addEventListener%28%27hashchange%27%2C%20query%29%3B%0A%7D%29%28%29%3B%0A
```


> **Share yours!**
> I'm actively looking for neat JS snippets to share here.
> Please open an Issue or Pull Request if you'd like to contribute.
