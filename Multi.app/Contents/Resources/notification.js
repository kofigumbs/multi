const NotificationClass = window.Notification

class MultiNotification {
  static #permission = "default"

  static get permission() {
    return MultiNotification.#permission
  }

  static requestPermission(callback) {
    const promise = webkit.messageHandlers.notificationRequest.postMessage({})
      .then(() => "granted", () => "denied")
      .then((permission) => MultiNotification.#permission = permission)
    promise.then(callback)
    return promise
  }

  constructor(...args) {
    const notification = new NotificationClass(...args)
    const message = {
      title: notification.title,
      tag: notification.tag ?? crypto.randomUUID(),
      body: notification.body,
      icon: notification.icon,
    }
    webkit.messageHandlers.notificationShow.postMessage(message)
    return new Proxy(notification, {
      get(_, prop) {
        return prop === "close"
          ? () => webkit.messageHandlers.notificationClose.postMessage(message)
          : Reflect.get(...arguments)
      },
    })
  }
}

window.Notification = MultiNotification
