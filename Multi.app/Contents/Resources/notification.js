window.Notification = class {
  static get permission() {
    return "granted";
  }
  static requestPermission(callback) {
    if (typeof callback === "function")
      callback(Notification.permission);
    return Promise.resolve(Notification.permission);
  }
  constructor(title, options = {}) {
    Object.assign(this, options);
    if (this.tag === undefined)
      this.tag = String(performance.now());
    window.webkit.messageHandlers.notify.postMessage({
      method: "show",
      tag: String(this.tag),
      title: String(title || ""),
      body: options.body,
      icon: options.icon ? new URL(options.icon, document.baseURI).href : null,
    });
  }
  close() {
    window.webkit.messageHandlers.notify.postMessage({
      method: "close",
      tag: String(this.tag),
    });
  }
};
