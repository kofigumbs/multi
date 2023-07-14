import SwiftUI
import WebKit
import MultiSettings

struct TabView: View {
    let tab: Config.Tab
    let onAppear: (NSWindow) -> Void

    var body: some View {
        ContentView { webView in
            onAppear(webView.window!)
            webView.load(URLRequest(url: tab.url))
        }
            .with(
                userAgent: tab.userAgent
                /// TODO ui: open, dialogs
                /// TODO navigation: open, basic auth
                /// TODO scripts: notifications, custom JS/CSS
                /// TODO cookies
                /// TODO handlers: notifications
            )
            .navigationTitle(tab.title)
    }
}
