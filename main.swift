import WebKit

let WINDOW_NAME = "Chat"

// These seem to be the right values for fullscreen on my 13-inch
let WINDOW_WIDTH = 1440
let WINDOW_HEIGHT = 1600
let VIEW_HEIGHT = 855 // not sure why this is so different

// Fake a more popular browser to circumvent UA-sniffing
let USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"


class Browser {
    let title: String
    private let webview: WKWebView

    private static let window: NSWindow = {
        let window = NSWindow.init(
            contentRect: NSMakeRect(0, 0, CGFloat(WINDOW_WIDTH), CGFloat(WINDOW_HEIGHT)),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: NSWindow.BackingStoreType.buffered,
            defer: false
        )
        window.cascadeTopLeft(from: .zero)
        window.title = WINDOW_NAME
        window.makeKeyAndOrderFront(nil)
        return window
    }()

    private init(_ title: String) {
        self.title = title
        self.webview = WKWebView(frame: CGRect(x: 0, y: 0, width: WINDOW_WIDTH, height: VIEW_HEIGHT))
        webview.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webview.customUserAgent = USER_AGENT
    }

    private convenience init(_ title: String, url: URL) {
        self.init(title)
        self.webview.load(URLRequest(url: url))
    }

    private convenience init(_ title: String, html: String) {
        self.init(title)
        self.webview.loadHTMLString(html, baseURL: nil)
    }

    @objc func view(_: Any? = nil) {
        Browser.window.contentView?.subviews.forEach { $0.removeFromSuperview() }
        Browser.window.contentView?.addSubview(webview)
    }


    /*
     * Configuration
     */

    private struct Config: Codable {
        let title: String
        let url: URL
    }

    private static func error(_ path: String, _ message: String) -> [Browser] {
        let html = """
            <!DOCTYPE html>
            <h1>Invalid configuration <code>\(path)</code></h1>
            <pre><code>\(message)</code></pre>
        """
        return [ Browser("Error", html: html) ]
    }

    static func configure(path: String) -> [Browser] {
        guard let file = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return error(path, "File does not exist")
        }
        guard let json = try? JSONDecoder().decode([Config].self, from: file) else {
            return error(path, "Required format is [{ title: String, url: String }]")
        }
        return json.isEmpty 
            ? error(path, "JSON is empty")
            : json.map { Browser($0.title, url: $0.url) }
    }
}


/*
 * DSL for nicer menu creation
 */

extension NSMenu {
    enum Entry {
        case one(String, String, AnyObject?, Selector)
        case sub(NSMenu)
    }

    func items(_ items: [Entry]) -> NSMenu {
        for item in items {
            switch item {
            case let .sub(menu):
                let i = NSMenuItem()
                i.submenu = menu
                addItem(i)
            case let .one(shortcut, title, target, selector):
                let i = NSMenuItem(title: title, action: selector, keyEquivalent: shortcut)
                i.target = target
                addItem(i)
            }
        }
        return self
    }
}


// Setup app

let browsers = Browser.configure(path: "./config.json")
browsers.first?.view()

NSApp.mainMenu = NSMenu().items([
    .sub(NSMenu().items([ .one("q", "Quit", nil, #selector(NSApplication.terminate)) ])),
    .sub(NSMenu(title: "Edit").items([
        .one("x", "Cut", nil, #selector(NSText.cut)),
        .one("c", "Copy", nil, #selector(NSText.copy)),
        .one("v", "Paste", nil, #selector(NSText.paste)),
        .one("a", "Select All", nil, #selector(NSText.selectAll)),
    ])),
    .sub(NSMenu(title: "View").items(
        browsers.enumerated().map { (index, browser) in
            NSMenu.Entry.one("\(index + 1)", browser.title, browser, #selector(Browser.view))
        }
    ))
])

let _ = NSApplication.shared
NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
