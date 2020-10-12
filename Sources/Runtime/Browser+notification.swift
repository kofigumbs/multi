import WebKit

extension Browser: WKScriptMessageHandler {
    func notification(_ configuration: WKWebViewConfiguration) {
        let js = """
            window.Notification = class {
                static get permission() {
                    return "granted";
                }
                static requestPermission(callback) {
                    if (typeof callback === "function")
                        callback(Notification.permission);
                    return Promise.resolve(Notification.permission);
                }
                constructor(...x) {
                    window.webkit.messageHandlers.notify.postMessage(x);
                }
            }
        """
        configuration.userContentController.addUserScript(
            WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        )
        configuration.userContentController.add(Browser.global, name: "notify")
    }

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let arguments = didReceive.body as? NSArray,
              let title = arguments[0] as? String else {
            return
        }
        let body = (arguments[1] as? NSObject)?.value(forKey: "body") as? String
        let notification = NSUserNotification()
        notification.identifier = UUID().uuidString
        notification.title = title
        notification.informativeText = body
        NSUserNotificationCenter.default.delegate = Browser.global
        NSUserNotificationCenter.default.deliver(notification)
    }
}
