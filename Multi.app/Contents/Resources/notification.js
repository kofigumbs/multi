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
    this._id = String(performance.now());
    window.webkit.messageHandlers.notify.postMessage([this._id, ...x]);
  }
  close() {
    window.webkit.messageHandlers.unnotify.postMessage([this._id]);
  }
};
