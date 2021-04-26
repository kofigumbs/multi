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
    }

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let options = didReceive.body as? NSDictionary,
              let tag = options["tag"] as? String else {
            return
        }
        switch options["method"] as? String {
            case "show":
                guard let title = options["title"] as? String else {
                    return
                }
                let notification = NSUserNotification()
                notification.identifier = tag
                notification.title = title
                notification.informativeText = options["body"] as? String
                notification.contentImage = (options["icon"] as? String).flatMap(URL.init(string:)).flatMap(NSImage.init(contentsOf:))
                NSUserNotificationCenter.default.delegate = Browser.global
                NSUserNotificationCenter.default.deliver(notification)
                Browser.notifications[tag] = (self, notification)
            case "close":
                Browser.notifications.removeValue(forKey: tag).map {
                    NSUserNotificationCenter.default.removeDeliveredNotification($0.1)
                }
            default:
                return
        }
    }
}
