# Custom CSS

Multi lets you add custom CSS (a.k.a. style injection) to any site in your Multi App.
The custom CSS is applied after each page in that tab is loaded.
Each custom CSS rule is specified with a URL, which gives you a few options for how you want to manage your styles:

1. Put your styles online, and use their URL: ex. `https://raw.githubusercontent.com/kofigumbs/multi/2.x/Assets/test.css`
2. Put your styles in a file on your computer, and reference them locally: ex. `file:///Users/kofi/Documents/multi/Assets/test.css`
3. Encode your styles directly in the Multi settings using [Data URIs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs): ex. `data:,body%20%7B%20background%3A%20mediumpurple%3B%20%7D`

## Examples

### Hide the sidebar on twitter.com

| CSS | CSS Data URI |
|-----|--------------|
| `[data-testid=sidebarColumn]{display:none}` | `data:,%5Bdata-testid%3DsidebarColumn%5D%7Bdisplay%3Anone%7D` |

![](/Assets/custom-css-twitter-sidebar.png)


> **Share yours!**
> I'm actively looking for neat CSS snippets to share here.
> Please open an Issue or Pull Request if you'd like to contribute.
