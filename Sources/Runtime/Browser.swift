import Shared
import WebKit

class Browser: NSObject {
    static let global = Browser()

    // Fake a more popular browser to circumvent UA-sniffing
    static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"

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
}
