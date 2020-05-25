import WebKit

class ExternalLink: NSObject, WKNavigationDelegate {
    static let singleton = ExternalLink()

    func webView(_: WKWebView, decidePolicyFor: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> () {
        switch decidePolicyFor.targetFrame {
        case .some(_):
            decisionHandler(.allow)
        case .none:
            decisionHandler(.cancel)
            _ = decidePolicyFor.request.url.map(NSWorkspace.shared().open)
        }
    }
}
