import WebKit

extension Tab: WKScriptMessageHandler {
    func notification(_ configuration: WKWebViewConfiguration) {
        guard let url = Bundle.multi?.url(forResource: "notification", withExtension: "js"),
              let js = try? String(contentsOf: url) else {
            return
        }
        configuration.userContentController.addUserScript(
            WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        )
        configuration.userContentController.add(self, name: "notify")
        configuration.userContentController.add(self, name: "unnotify")
    }

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let arguments = didReceive.body as? NSArray,
              let id = arguments[0] as? String else {
            return
        }
        if (didReceive.name == "unnotify" ) {
            Browser.notifications.removeValue(forKey: id).map {
                NSUserNotificationCenter.default.removeDeliveredNotification($0.1)
            }
            return
        }
        guard let title = arguments[1] as? String else {
            return
        }
        let notification = NSUserNotification()
        notification.identifier = id
        notification.title = title
        notification.informativeText = option("body", arguments)
        NSUserNotificationCenter.default.delegate = Browser.global
        NSUserNotificationCenter.default.deliver(notification)
        Browser.notifications[id] = (self, notification)
    }

    private func option(_ name: String, _ arguments: NSArray) -> String? {
        return (arguments[2] as? NSObject)?.value(forKey: name) as? String
    }
}
