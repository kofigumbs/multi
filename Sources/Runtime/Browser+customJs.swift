import WebKit

extension Browser {
    func customJs(_ configuration: WKWebViewConfiguration, urls: [URL]) {
        guard !urls.isEmpty else { return }
        urls.compactMap { try? String(contentsOf: $0) }.forEach { js in
            configuration.userContentController.addUserScript(
                WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            )
        }
    }
}
