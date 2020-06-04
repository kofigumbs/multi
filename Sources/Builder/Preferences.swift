import WebKit

struct Preferences {
    static let form = Form()

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
        let path = Bundle.main.path(forResource: "preferences", ofType: "html")!
        let html = try! String(contentsOf: URL(fileURLWithPath: path))
        let webView = WKWebView(frame: window.frame)
        webView.setValue(false, forKey: "drawsBackground")
        webView.configuration.userContentController.add(form.icon, name: "icon")
        webView.configuration.userContentController.add(form, name: "save")
        webView.loadHTMLString(html, baseURL: nil)
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        window.contentView = webView
    }
}
