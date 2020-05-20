import Cocoa
import WebKit

// <https://stackoverflow.com/a/46348417>
let _ = NSApplication.shared
NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)

let menu = NSMenu()
let item = NSMenuItem()
let subment = NSMenu()
menu.addItem(item)
item.submenu = subment
NSApp.mainMenu = menu
subment.addItem(NSMenuItem.init(
    title: "Quit",
    action: #selector(NSApplication.terminate),
    keyEquivalent: "q"
));

let bounds = NSMakeRect(0, 0, 1440, 1600)
let window = NSWindow.init(
    contentRect: bounds,
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: NSWindow.BackingStoreType.buffered,
    defer: false
)
window.cascadeTopLeft(from: .zero)
window.title = ProcessInfo.processInfo.processName;
window.makeKeyAndOrderFront(nil)

let webview = WKWebView(frame: CGRect(x: 0, y: 0, width: 1440, height: 860))
window.contentView?.addSubview(webview)
webview.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"; // Copied from Safari, required for Slack
_ = webview.load(URLRequest(url: URL(string: "https://app.slack.com/client")!))

NSApp.activate(ignoringOtherApps: true)
NSApp.run()
