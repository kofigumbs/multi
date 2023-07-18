import SwiftUI
import AppKit
import WebKit
import UserNotifications
import MultiSettings

class AppDelegate: NSObject {
    var openWindow: OpenWindowAction?

    let config: Config = {
        guard let url = Bundle.main.url(forResource: "config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(Config.self, from: data),
              !config.tabs.isEmpty else {
            return Config(tabs: [Config.Tab(url: SettingsView.url(cannotOpenResource: "config.json"))])
        }
        return config
    }()

    func openExternal(url: URL) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = !config.openNewWindowsInBackground
        if let application = config.openNewWindowsWith,
           let applicationURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: application) {
            NSWorkspace.shared.open([url], withApplicationAt: applicationURL, configuration: configuration)
        } else {
            NSWorkspace.shared.open(url, configuration: configuration)
        }
    }
}

extension AppDelegate: NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return config.terminateWithLastWindow
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let index = response.notification.request.content.userInfo["tab"] as? Int,
              config.tabs.indices.contains(index) else {
            return
        }
        DispatchQueue.main.async {
            self.openWindow?(value: index)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        config.alwaysNotify ? .banner : []
    }
}

extension AppDelegate: WKUIDelegate {
    func webView(_: WKWebView, createWebViewWith: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        _ = navigationAction.request.url.map(openExternal)
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage: String, initiatedByFrame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = runJavaScriptAlertPanelWithMessage
        alert.beginSheetModal(for: webView.window!) { _ in completionHandler() }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage: String, initiatedByFrame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = runJavaScriptConfirmPanelWithMessage
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: webView.window!) { response in completionHandler(response == .alertFirstButtonReturn) }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt: String, defaultText: String?, initiatedByFrame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = NSAlert()
        let field = NSTextField(string: defaultText ?? "")
        field.frame = NSRect(x: alert.window.contentLayoutRect.minX, y: field.frame.minY, width: alert.window.contentLayoutRect.width, height: field.frame.height)
        alert.accessoryView = field
        alert.messageText = runJavaScriptTextInputPanelWithPrompt
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: webView.window!) { response in completionHandler(response == .alertFirstButtonReturn ? field.stringValue : nil) }
        alert.window.makeFirstResponder(field)
    }

    func webView(_ webView: WKWebView, runOpenPanelWith: WKOpenPanelParameters, initiatedByFrame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = runOpenPanelWith.allowsDirectories
        openPanel.allowsMultipleSelection = runOpenPanelWith.allowsMultipleSelection
        openPanel.beginSheetModal(for: webView.window!) { _ in completionHandler(openPanel.urls) }
    }
}
