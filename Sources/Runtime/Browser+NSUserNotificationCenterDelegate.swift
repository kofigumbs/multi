import AppKit

extension Browser: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent: NSUserNotification) -> Bool {
        return Config.alwaysNotify
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        guard let id = notification.identifier,
              let tab = Browser.notifications[id]?.0 else {
            return
        }
        tab.view()
    }
}
