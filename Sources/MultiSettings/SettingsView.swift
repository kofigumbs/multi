import SwiftUI
import WebKit

public struct SettingsView: View {
    let overwrite: Bool

    public init(overwrite: Bool) {
        self.overwrite = overwrite
    }

    var html: String {
        guard let url = Bundle.multi?.url(forResource: "preferences", withExtension: "html"),
              let html = try? String(contentsOf: url) else {
            return """
                <!DOCTYPE html>
                Cannot open <code>preferences.html</code>.
            """
        }
        // TODO inject initialize script or add another delegete message
        return html
    }

    public var body: some View {
        ContentView(handlers: [:]) { webView in
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}
