import WebKit
import MultiSettings

class TabDelegate: NSObject, WKNavigationDelegate {
    let tab: Config.Tab
    let app: AppDelegate

    init(_ tab: Config.Tab, _ app: AppDelegate) {
        self.tab = tab
        self.app = app
    }

    func webView(_: WKWebView, decidePolicyFor: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> () {
        if decidePolicyFor.targetFrame != nil || decidePolicyFor.request.url?.scheme == "about" {
            decisionHandler(.allow)
        }
        else {
            decisionHandler(.cancel)
            _ = decidePolicyFor.request.url.map(app.openExternal)
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

