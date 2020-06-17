import WebKit

public class Preferences: NSObject {
    private let form: Form
    private let script: String

    public static let create: Preferences = { .init(form: Form(Archive.create), script: "") }()
    public static let update: Preferences = { .init(form: Form(Archive.update), script: "document.getElementById('name').disabled = true") }()

    private init(form: Form, script: String) {
        self.form = form
        self.script = script
    }

    static let window: NSWindow = {
        Program.window(
            title: Program.title,
            contentRect: NSScreen.main!.frame.applying(.init(scaleX: 0.5, y: 0.5)),
            styleMask: [.titled, .closable, .miniaturizable, .resizable]
        )
    }()

    @objc public func view(_: Any? = nil) {
        // TODO don't rely on Bundle.main (this can be run from preferences)
        let url = Bundle.main.url(forResource: "preferences", withExtension: "html")!
        let html = try! String(contentsOf: url)
        let webView = WKWebView(frame: Preferences.window.frame)
        webView.setValue(false, forKey: "drawsBackground")
        webView.configuration.userContentController.add(form.icon, name: "icon")
        webView.configuration.userContentController.add(form, name: "save")
        webView.loadHTMLString(html, baseURL: nil)
        webView.enableDevelop()
        webView.evaluateJavaScript(script)
        Preferences.window.contentView = webView
    }
}
