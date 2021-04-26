import AppKit

extension Browser: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent: NSUserNotification) -> Bool {
        return Config.alwaysNotify
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        guard let i = notification.userInfo?["tab"] as? Int,
              i < Config.tabs.count else {
            return
        }
        Config.tabs[i].view()
    }
}
