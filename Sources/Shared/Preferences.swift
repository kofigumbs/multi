import WebKit

public class Preferences: NSObject {
    private let form: Form
    private let script: String

    public var menuItems: [NSMenuItem] {
        return [
            NSMenuItem(title: "Preferences", action: #selector(Preferences.view(_:)), keyEquivalent: ",", target: self),
            .separator(),
        ]
    }

    public static let create: Preferences = {
        .init(
            form: Form(overwrite: false),
            name: "",
            json: """
              {
                "tabs": [
                  {
                    "title": "Your first Multi app",
                    "url": "https://github.com/hkgumbs/multi#json-configuration"
                  }
                ]
              }
              """
        )
    }()

    public static let update: Preferences = {
        .init(
            form: Form(overwrite: true),
            name: Bundle.main.title ?? "",
            json: Bundle.main.url(forResource: "config", withExtension: "json").flatMap { try? String(contentsOf: $0) } ?? "{}"
        )
    }()


    private init(form: Form, name: String, json: String) {
        self.form = form
        self.script = """
            load({
              name: '\(name.data(using: .utf8)?.base64EncodedString() ?? "")',
              json: '\(json.data(using: .utf8)?.base64EncodedString() ?? "")',
            })
            """
    }

    static let window: NSWindow = {
        let window = Program.window(
            title: Program.title,
            contentRect: NSScreen.main!.frame.applying(.init(scaleX: 0.5, y: 0.5)),
            styleMask: [.titled, .closable, .miniaturizable, .resizable]
        )
        window.isReleasedWhenClosed = false
        return window
    }()

    @objc public func view(_: Any? = nil) {
        guard let url = Bundle.multi?.url(forResource: "preferences", withExtension: "html"),
              let html = try? String(contentsOf: url) else {
            _ = Program.errorWindow(message: "Multi.app is missing essential files — try re-installing it.")
            return
        }
        let webView = WKWebView(frame: Preferences.window.frame)
        webView.setValue(false, forKey: "drawsBackground")
        webView.configuration.userContentController.add(form.icon, name: "icon")
        webView.configuration.userContentController.add(form, name: "save")
        webView.configuration.userContentController.addUserScript(WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        webView.loadHTMLString(html, baseURL: nil)
        webView.enableDevelop()
        Preferences.window.contentView = webView
        Preferences.window.makeKeyAndOrderFront(nil)
    }
}
