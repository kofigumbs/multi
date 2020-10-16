import WebKit

extension WKWebView {
    public func enableDevelop() {
        self.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    }
}
