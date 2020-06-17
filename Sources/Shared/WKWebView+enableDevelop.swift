import WebKit

extension WKWebView {
    public func enableDevelop() {
        #if DEBUG
        self.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
    }
}
