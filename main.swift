import WebKit

// Setup app
let _ = NSApplication.shared
NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)

class Tab : Codable {
    let title: String
    let url: URL

    static var window: NSWindow?
    static var webviews: [WKWebView]?
    @objc static func change(any: Any?) {
        guard let item = any as? NSMenuItem,
              let index = Int(item.keyEquivalent),
              let contentView = window?.contentView,
              let activeTab = webviews?[index - 1]
              else { return }
        contentView.subviews.forEach { view in view.removeFromSuperview() }
        contentView.addSubview(activeTab)
    }
}
let decoder = JSONDecoder()
let config = try decoder.decode(
    [Tab].self,
    from: Data(contentsOf: URL(fileURLWithPath: "config.json")))

// Setup web views
let window = NSWindow.init(
    contentRect: NSMakeRect(0, 0, 1440, 1600),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: NSWindow.BackingStoreType.buffered,
    defer: false
)
window.cascadeTopLeft(from: .zero)
window.title = ProcessInfo.processInfo.processName;
window.makeKeyAndOrderFront(nil)

let webviews: [WKWebView] = config.map { tab in
    let webview = WKWebView(frame: CGRect(x: 0, y: 0, width: 1440, height: 855))
    webview.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    webview.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"; // Copied from Safari, required for Slack
    _ = webview.load(URLRequest(url: tab.url))
    return webview
}
window.contentView?.addSubview(webviews.first!)

Tab.window = window
Tab.webviews = webviews

// Setup menu
let appMenuItem = NSMenuItem()
let appMenu = NSMenu()
appMenuItem.submenu = appMenu
appMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "q"));

let editMenuItem = NSMenuItem()
let editMenu = NSMenu(title: "Edit")
editMenuItem.submenu = editMenu
editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))

let viewMenuItem = NSMenuItem()
let viewMenu = NSMenu(title: "View")
viewMenuItem.submenu = viewMenu
for (index, tab) in config.enumerated() {
    let item = NSMenuItem(title: tab.title, action: #selector(Tab.change), keyEquivalent: "\(index + 1)")
    item.target = Tab.self
    viewMenu.addItem(item)
}

let mainMenu = NSMenu()
mainMenu.addItem(appMenuItem)
mainMenu.addItem(editMenuItem)
mainMenu.addItem(viewMenuItem)
NSApp.mainMenu = mainMenu

// Run!
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
