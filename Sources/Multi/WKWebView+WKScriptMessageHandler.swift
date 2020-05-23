import WebKit

/*
 * Notifications
 */
extension WKWebView: WKScriptMessageHandler {
    private static let JS =
        "window.Notification = class {                               " +
        "    static get permission() {                               " +
        "        return 'granted';                                   " +
        "    }                                                       " +
        "    static requestPermission(callback) {                    " +
        "        if (typeof callback === 'function')                 " +
        "            callback(Notification.permission);              " +
        "        return Promise.resolve(Notification.permission);    " +
        "    }                                                       " +
        "    constructor(...x) {                                     " +
        "        window.webkit.messageHandlers.notify.postMessage(x);" +
        "    }                                                       " +
        "}"

    func bridgeNotifications() {
        let script = WKUserScript(source: WKWebView.JS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.configuration.userContentController.addUserScript(script)
        self.configuration.userContentController.add(self, name: "notify")
    }

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let arguments = didReceive.body as? NSArray,
              let title = arguments[0] as? String,
              let options = arguments[1] as? NSObject,
              let body = options.value(forKey: "body") as? String else {
            return
        }
        let notification = NSUserNotification()
        notification.identifier = UUID().uuidString
        notification.title = title
        notification.informativeText = body
        NSUserNotificationCenter.default.deliver(notification)
    }
}
