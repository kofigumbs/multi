import WebKit
import MultiSettings

class TabViewDelegate: NSObject, WKNavigationDelegate {
    let tab: Config.Tab
    let appDelegate: RuntimeDelegate

    init(_ tab: Config.Tab, _ appDelegate: RuntimeDelegate) {
        self.tab = tab
        self.appDelegate = appDelegate
    }

    func webView(_: WKWebView, decidePolicyFor: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> () {
        if let _ = decidePolicyFor.targetFrame {
            decisionHandler(.allow)
        }
        else {
            decisionHandler(.cancel)
            _ = decidePolicyFor.request.url.map(appDelegate.openExternal)
        }
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            completionHandler(.useCredential, URLCredential(user: tab.basicAuthUser, password: tab.basicAuthPassword, persistence: .forSession))
        }
        else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

