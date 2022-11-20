import AppKit

extension Browser: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent: NSUserNotification) -> Bool {
        return Config.alwaysNotify
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        guard let i = notification.userInfo?["tab"] as? Int,
              Config.tabs.indices.contains(i) else {
            return
        }
        Config.tabs[i].view()
    }
}
