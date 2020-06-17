import Shared
import WebKit

class Browser: NSObject {
    static let global = Browser()

    static let title = (Bundle.stub?.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "Multi"

    // Fake a more popular browser to circumvent UA-sniffing
    static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"

    static let blocklist: String = {
        guard let url = Bundle.stub?.url(forResource: "blocklist", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json.lowercased()
    }()

    static let window: NSWindow = {
        Program.window(
            title: title,
            contentRect: NSScreen.main!.frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable]
        )
    }()

    @objc func nextTab(_: Any? = nil) {
        Browser.shiftTab(by: 1)
    }

    @objc func previousTab(_: Any? = nil) {
        Browser.shiftTab(by: Config.tabs.count - 1)
    }

    private static func shiftTab(by diff: Int) {
        for (index, tab) in Config.tabs.enumerated() {
            if tab.webView == window.contentView {
                Config.tabs[(index + diff) % Config.tabs.count].view()
                return
            }
        }
    }
}
