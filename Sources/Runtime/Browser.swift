import Shared
import WebKit

class Browser: NSObject {
    static let global = Browser()

    static let blocklist: String = {
        guard let url = Bundle.multi?.url(forResource: "blocklist", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json.lowercased()
    }()

    static func window(title: String, webView: WKWebView) -> NSWindow {
        let window = Program.window(
            title: title,
            contentRect: NSScreen.main!.frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable]
        )
        window.setFrameAutosaveName(title)
        webView.frame = window.frame
        window.contentView = webView
        window.tabbingMode = .preferred
        if Config.alwaysOnTop {
            window.level = .floating
        }
        return window
    }

    func `open`(url: URL) {
        guard #available(macOS 10.15, *) else {
            NSWorkspace.shared.open(url)
            return
        }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = !Config.openNewWindowsInBackground
        if let application = Config.openNewWindowsWith,
           let applicationURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: application) {
            NSWorkspace.shared.open([url], withApplicationAt: applicationURL, configuration: configuration)
        } else {
            NSWorkspace.shared.open(url, configuration: configuration)
        }
    }

    func customCss(_ configuration: WKWebViewConfiguration, urls: [URL]) {
        guard !urls.isEmpty else { return }
        let css = urls
            .compactMap { try? String(contentsOf: $0) }
            .joined()
            .data(using: .utf8)?
            .base64EncodedString()
        let js = """
            const style = document.createElement("style");
            style.innerText = atob("\(css ?? "")");
            document.querySelector("head").insertAdjacentElement("beforeend", style);
        """
        configuration.userContentController.addUserScript(
            WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        )
    }

    func customJs(_ configuration: WKWebViewConfiguration, urls: [URL]) {
        guard !urls.isEmpty else { return }
        urls.compactMap { try? String(contentsOf: $0) }.forEach { js in
            configuration.userContentController.addUserScript(
                WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            )
        }
    }

    func customCookies(_ configuration: WKWebViewConfiguration, cookies: [Config.Schema.Cookie]) {
        cookies.forEach { cookie in
            let properties: [HTTPCookiePropertyKey: Any?] = [
                .name: cookie.name,
                .path: cookie.path,
                .value: cookie.value,
                .comment: cookie.comment,
                .commentURL: cookie.commentURL,
                .discard: cookie.discard,
                .domain: cookie.domain,
                .expires: cookie.expires,
                .maximumAge: cookie.maximumAge,
                .originURL: cookie.originURL,
                .port: cookie.port,
                .secure: cookie.secure,
                .version: cookie.version,
            ]
            if let cookie = HTTPCookie(properties: properties.compactMapValues { $0 }) {
                configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
    }
}
