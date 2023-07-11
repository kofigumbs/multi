import WebKit

extension WKWebView {
    @objc
    func actualSize(_: Any? = nil) {
        pageZoom = 1.0
    }

    @objc
    func zoomIn(_: Any? = nil) {
        pageZoom *= 1.1
    }

    @objc
    func zoomOut(_: Any? = nil) {
        pageZoom /= 1.1
    }
}
