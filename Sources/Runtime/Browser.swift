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

    func customCookie(_ configuration: WKWebViewConfiguration, cookies: [Config.Schema.Cookie]) {
        guard !cookies.isEmpty else { return }

        cookies.forEach { values in
            var props: [HTTPCookiePropertyKey : Any] = [
                .name: values.name,
                .path: values.path,
                .value: values.value
            ]

            if let comment = values.comment {
                props[.comment] = comment
            }
            if let commentURL = values.commentURL {
                props[.commentURL] = commentURL
            }
            if let discard = values.discard {
                props[.discard] = discard
            }
            if let domain = values.domain {
                props[.domain] = domain
            }
            if let expires = values.expires {
                props[.expires] = expires
            }
            if let maximumAge = values.maximumAge {
                props[.maximumAge] = maximumAge
            }
            if let originURL = values.originURL {
                props[.originURL] = originURL
            }
            if let port = values.port {
                props[.port] = port
            }
            if let secure = values.secure {
                props[.secure] = secure
            }
            if let version = values.version {
                props[.version] = version
            }

            if let cookie = HTTPCookie(properties: props) {
                configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
    }
}
