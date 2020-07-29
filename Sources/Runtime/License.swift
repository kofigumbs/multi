import Shared
import WebKit

class License: NSObject, WKScriptMessageHandler {
    static let global = License()

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let key = didReceive.body as? String,
              let relaunch = Bundle.Multi.main?.url(forResource: "relaunch", withExtension: nil) else {
            return
        }
        License.defaults { $0.set(key, forKey: $1) }
        _ = Script.run(relaunch, environment: [
            "APP_LOCATION": Bundle.Multi.stub?.bundlePath ?? "",
            "RELAUNCH_PID": "\(ProcessInfo.processInfo.processIdentifier)",
        ])
    }

    static let isValid: Bool = {
        guard let key = defaults({ $0.string(forKey: $1) }),
              let validate = URL(string: "https://gumbs.llc/multi/license/validate?key=\(key)") else {
            return false
        }
        guard let code = try? Data(contentsOf: validate, options: .uncached) else {
            // This means the HTTP request itself failed (maybe due to a bad
            // internet connection). The Multi app likely won't work anyway.
            // Just give users the benefit of the doubt.
            return true
        }
        return String(data: code, encoding: .utf8) == "0"
    }()

    private static func defaults <A> (_ use: (UserDefaults, String) -> A?) -> A? {
        return UserDefaults(suiteName: "gumbs.llc").flatMap { userDefaults in
            use(userDefaults, "multi.license")
        }
    }
}
