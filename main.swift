import WebKit

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
        window.title = ProcessInfo.processInfo.processName
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
     * CONFIGURATION
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


let browsers = Browser.configure(path: "./config.json")
browsers.first?.view()

// Setup menu
let appMenuItem = NSMenuItem()
let appMenu = NSMenu()
appMenuItem.submenu = appMenu
appMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q"))

let editMenuItem = NSMenuItem()
let editMenu = NSMenu(title: "Edit")
editMenuItem.submenu = editMenu
editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut), keyEquivalent: "x"))
editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy), keyEquivalent: "c"))
editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste), keyEquivalent: "v"))
editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll), keyEquivalent: "a"))

let viewMenuItem = NSMenuItem()
let viewMenu = NSMenu(title: "View")
viewMenuItem.submenu = viewMenu
for (index, browser) in browsers.enumerated() {
    let item = NSMenuItem(title: browser.title, action: #selector(Browser.view), keyEquivalent: "\(index + 1)")
    item.target = browser
    viewMenu.addItem(item)
}

let mainMenu = NSMenu()
mainMenu.addItem(appMenuItem)
mainMenu.addItem(editMenuItem)
mainMenu.addItem(viewMenuItem)

// Setup app
let _ = NSApplication.shared
NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
NSApp.mainMenu = mainMenu
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
