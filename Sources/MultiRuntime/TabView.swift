import SwiftUI
import WebKit
import MultiSettings

struct TabView: View {
    let tab: Config.Tab
    let onAppear: (NSWindow) -> Void

    var body: some View {
        ContentView(scripts: [], handlers: [:]) { webView in
            /// TODO custom CSS
            /// TODO custom JS
            /// TODO custom cookies
            /// TODO user agent
            /// TODO basic auth
            /// TODO ui delegate
            /// TODO navigation delegate
            /// TODO notifications
            onAppear(webView.window!)
            webView.load(URLRequest(url: tab.url))
        }
            .navigationTitle(tab.title)
    }
}
