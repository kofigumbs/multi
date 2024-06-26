import SwiftUI
import UserNotifications
import WebKit
import MultiSettings

struct TabView: View {
    struct Error: Swift.Error {
        let message: String
    }

    let index: Int
    let delegate: TabViewDelegate
    let onPresent: (NSWindow) -> Void

    var notificationPolyfill: [WKUserScript] {
        guard let url = SettingsView.url(forResource: "notification.js"),
              let js = try? String(contentsOf: url) else {
            return []
        }
        return [WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)]
    }

    var customCss: [WKUserScript] {
        delegate.tab.customCss.compactMap({ try? Data(contentsOf: $0).base64EncodedString() }).map { css in
            WKUserScript(
                source: """
                document.documentElement.prepend(
                    Object.assign(document.createElement("style"), { innerText: atob("\(css)") })
                )
                """,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
        }
    }

    var customJs: [WKUserScript] {
        delegate.tab.customJs.compactMap({ try? String(contentsOf: $0) }).map { js in
            WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        }
    }

    var cookies: [HTTPCookie] {
        delegate.tab.customCookies.compactMap { cookie in
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
            return HTTPCookie(properties: properties.compactMapValues { $0 })
        }
    }

    var body: some View {
        ContentView(
            userAgent: delegate.tab.userAgent,
            ui: delegate.appDelegate,
            navigation: delegate,
            scripts: notificationPolyfill + customCss + customJs,
            cookies: cookies,
            handlers: [
                "notificationRequest": notificationRequest,
                "notificationShow": notificationShow,
                "notificationClose": notificationClose,
            ]
        ) { webView in
            onPresent(webView.window!)
            webView.load(URLRequest(url: delegate.tab.url))
        }
            .navigationTitle(delegate.tab.title)
    }

    func notificationRequest(_: NSObject) async throws {
        guard try await UNUserNotificationCenter.current().requestAuthorization() else {
            throw Error(message: "Notification permission denied")
        }
    }

    func notificationShow(message: NSObject) async throws {
        guard let tag = message.value(forKey: "tag") as? String else {
            throw Error(message: "Notification tag is required")
        }
        let content = UNMutableNotificationContent()
        content.title = message.value(forKey: "title") as? String ?? ""
        content.body = message.value(forKey: "body") as? String ?? ""
        content.userInfo = ["tab": index]
        try await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: tag, content: content, trigger: nil))
    }

    func notificationClose(message: NSObject) async throws {
        guard let tag = message.value(forKey: "tag") as? String else {
            throw Error(message: "Notification tag is required")
        }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [tag])
    }
}
