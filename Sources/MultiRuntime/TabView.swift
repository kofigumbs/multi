import SwiftUI
import WebKit
import MultiSettings

struct TabView: View {
    let tab: Config.Tab
    let onAdd: (NSWindow) -> Void

    let blocklist: String = {
        guard let url = Bundle.multi?.url(forResource: "blocklist", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json.lowercased()
    }()

    var body: some View {
        ContentView(scripts: [], handlers: [:]) { webView in
            /// TODO custom CSS
            /// TODO custom JS
            /// TODO user agent
            /// TODO basic auth
            /// TODO ui delegate
            /// TODO navigation delegate
            /// TODO notifications
            DispatchQueue.main.async {
                onAdd(webView.window!)
            }
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: blocklist) { (rules, error) in
                rules.map { webView.configuration.userContentController.add($0) }
                webView.load(URLRequest(url: tab.url))
            }
        }
            .navigationTitle(tab.title)
    }
}
