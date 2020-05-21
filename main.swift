import WebKit

let WINDOW_NAME = "Chat"

// These seem to be the right values for fullscreen on my 13-inch
let WINDOW_WIDTH = 1440
let WINDOW_HEIGHT = 1600
let VIEW_HEIGHT = 855 // not sure why this is so different

// Fake a more popular browser to circumvent UA-sniffing
let USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"


/*
 * WebKit UI wrappers
 */
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
        webview.customUserAgent = USER_AGENT
        webview.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webview.bridgeNotifications()
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
}


/*
 * Notifications
 */
extension WKWebView: WKScriptMessageHandler {
    func bridgeNotifications() {
        let js = """
            window.Notification = class {
                static get permission() {
                    return "granted";
                }
                static requestPermission(callback) {
                    if (typeof callback === "function")
                        callback(Notification.permission);
                    return Promise.resolve(Notification.permission);
                }
                constructor(...x) {
                    window.webkit.messageHandlers.notify.postMessage(x);
                }
            }
        """
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.configuration.userContentController.addUserScript(script)
        self.configuration.userContentController.add(self, name: "notify")
    }

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let arguments = didReceive.body as? NSArray,
              let title = arguments[0] as? String,
              let options = arguments[1] as? NSObject,
              let body = options.value(forKey: "body") as? String else {
            print(didReceive.body)
            return
        }
        let notification = NSUserNotification()
        notification.identifier = UUID().uuidString
        notification.title = title
        notification.informativeText = body
        // NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }

    // public func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent: NSUserNotification) -> Bool {
    //     print(dump(shouldPresent))
    //     return true
    // }
}


/*
 * Shim for Swift scripts <https://gist.github.com/rsattar/ed74982428003db8e875>
 */
extension Bundle {
    @objc func bundleIdentifier_shim() -> NSString {
        return self == Bundle.main
            ? "main.bundle.id.shim"
            : self.bundleIdentifier_shim() // Not recursive! See transformation below
    }

    static func setupScriptIdentifier() {
        if let aClass = objc_getClass("NSBundle") as? AnyClass {
            method_exchangeImplementations(
                class_getInstanceMethod(aClass, #selector(getter: Bundle.bundleIdentifier))!,
                class_getInstanceMethod(aClass, #selector(Bundle.bundleIdentifier_shim))!
            )
        }
    }
}


/*
 * Configuration
 */
extension Browser {
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
    struct Entry {
        let item: NSMenuItem

        static func sub(_ menu: NSMenu) -> Entry {
            let entry = Entry(item: NSMenuItem())
            entry.item.submenu = menu
            return entry
        }

        static func shortcut(_ keyEquivalent: String, _ title: String, _ action: Selector) -> Entry {
            return Entry(
                item: NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
            )
        }

        func target(_ this: AnyObject) -> Entry {
            self.item.target = this
            return self
        }
    }

    func items(_ items: [Entry]) -> NSMenu {
        items.forEach { addItem($0.item) }
        return self
    }
}


/*
 * "main"
 */
Bundle.setupScriptIdentifier()

let browsers = Browser.configure(path: "./config.json")
browsers.first?.view()

NSApp.mainMenu = NSMenu().items([
    .sub(NSMenu().items([ .shortcut("q", "Quit", #selector(NSApplication.terminate)) ])),
    .sub(NSMenu(title: "Edit").items([
        .shortcut("x", "Cut", #selector(NSText.cut)),
        .shortcut("c", "Copy", #selector(NSText.copy)),
        .shortcut("v", "Paste", #selector(NSText.paste)),
        .shortcut("a", "Select All", #selector(NSText.selectAll)),
    ])),
    .sub(NSMenu(title: "View").items(
        browsers.enumerated().map { (index, browser) in
            NSMenu.Entry
                .shortcut("\(index + 1)", browser.title, #selector(Browser.view))
                .target(browser)
        }
    ))
])

let _ = NSApplication.shared
NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
