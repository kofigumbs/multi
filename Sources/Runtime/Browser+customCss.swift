import WebKit

extension Browser {
    func customCss(_ configuration: WKWebViewConfiguration, urls: [URL]) {
        guard !urls.isEmpty else { return }
        let css = urls
            .compactMap { try? String(contentsOf: $0) }
            .joined()
            .data(using: .utf8)?
            .base64EncodedString()
        let js = """
            const style = document.createElement("style");
            style.innerText = atob("\(css ?? "")");
            document.querySelector("head").insertAdjacentElement("beforeend", style);
        """
        configuration.userContentController.addUserScript(
            WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        )
    }
}
