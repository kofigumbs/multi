import WebKit

struct Preferences {
    static let icon = Icon()

    static let window: NSWindow = {
        let window = NSWindow(
            contentRect: NSScreen.main!.frame.applying(.init(scaleX: 0.5, y: 0.5)),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: NSWindow.BackingStoreType.buffered,
            defer: false
        )
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        window.title = "Multi" + (version == nil ? "" : " — \(version!)")
        window.titlebarAppearsTransparent = true
        window.makeKeyAndOrderFront(nil)
        window.center()
        return window
    }()

    static func view() {
        let path = Bundle.main.path(forResource: "builder", ofType: "html")!
        let html = try! String(contentsOf: URL(fileURLWithPath: path))
        let webView = WKWebView(frame: window.frame)
        webView.setValue(false, forKey: "drawsBackground")
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webView.configuration.userContentController.add(icon, name: "icon")
        webView.loadHTMLString(html, baseURL: nil)
        window.contentView = webView
    }
}
