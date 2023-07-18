import WebKit

class ContentViewDelegate: NSObject, WKScriptMessageHandlerWithReply {
    var handlers = [String: (NSObject) async throws -> Any]()

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {
        guard let handler = handlers[message.name] else {
            return (nil, "NoMessageHandler")
        }
        do {
            let result = try await handler(message.body as? NSObject ?? NSNull())
            return (result is Void ? nil : result, nil)
        }
        catch {
            return (nil, String(describing: error))
        }
    }
}
