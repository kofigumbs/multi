import Shared
import WebKit

extension WKWebView {
    func setDefaultZoom() {
        // TODO set this from UserDefaults... the naive approach isn't working for some reason tho
    }

    @objc func actualSize(_: Any? = nil) {
        setZoom("1")
    }

    @objc func zoomIn(_: Any? = nil) {
        setZoom("zoom * 1.1")
    }

    @objc func zoomOut(_: Any? = nil) {
        setZoom("zoom / 1.1")
    }

    private func setZoom(_ rhs: String) {
        let js = """
            var zoom = document.body.style.zoom || 1;
            document.body.style.zoom = \(rhs);
        """
        self.evaluateJavaScript(js) { (result, error) in
            if let _ = result,
               let zoom = result! as? Double,
               let defaultKey = self.defaultKey() {
                UserDefaults.standard.set(zoom, forKey: defaultKey)
            }
        }
    }

    private func defaultKey() -> String? {
       self.url?.host.map { "webview-zoom:\($0)" }
    }
}
