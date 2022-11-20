import WebKit

extension Tab: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let options = didReceive.body as? NSDictionary else {
            return
        }
        switch options["method"] as? String {
            case "show":
                guard let tag = options["tag"] as? String,
                      let title = options["title"] as? String else {
                    return
                }
                let notification = NSUserNotification()
                notification.identifier = tag
                notification.title = title
                notification.informativeText = options["body"] as? String
                notification.contentImage = (options["icon"] as? String).flatMap(URL.init(string:)).flatMap(NSImage.init(contentsOf:))
                notification.userInfo = Config.tabs.firstIndex(of: self).map { ["tab": $0] }
                NSUserNotificationCenter.default.delegate = Browser.global
                NSUserNotificationCenter.default.deliver(notification)
            case "close":
                guard let tag = options["tag"] as? String else {
                    return
                }
                NSUserNotificationCenter.default.deliveredNotifications
                    .filter { $0.identifier == tag }
                    .forEach(NSUserNotificationCenter.default.removeDeliveredNotification)
            case "badge":
                guard let count = options["count"] as? Int else {
                    return
                }
                self.badgeCount = count
                let total = Config.tabs.map { $0.badgeCount }.reduce(0, +)
                NSApp.dockTile.badgeLabel = total == 0 ? "" : "\(total)"
            default:
                return
        }
    }
}
