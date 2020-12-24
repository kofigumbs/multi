import WebKit

extension Tab: WKNavigationDelegate {
    func webView(_ this: WKWebView, didCommit: WKNavigation!) {
        this.setDefaultZoom()
    }

    func webView(_: WKWebView, decidePolicyFor: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> () {
        switch decidePolicyFor.targetFrame {
        case .some(_):
            decisionHandler(.allow)
        case .none:
            decisionHandler(.cancel)
            _ = decidePolicyFor.request.url.map(Browser.global.open)
        }
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        switch challenge.protectionSpace.authenticationMethod {
        case NSURLAuthenticationMethodHTTPBasic:
            completionHandler(.useCredential, URLCredential(user: self.basicAuthUser, password: self.basicAuthPassword, persistence: .forSession))
        default:
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
