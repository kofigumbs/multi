import Shared
import WebKit

class License: NSObject, WKScriptMessageHandler {
    static let global = License()

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let key = didReceive.body as? String,
              let relaunch = Bundle.multi?.url(forResource: "relaunch", withExtension: nil) else {
            return
        }
        License.defaults { $0.set(key, forKey: $1) }
        _ = Script.run(relaunch, environment: [
            "APP_LOCATION": Bundle.main.bundlePath,
            "RELAUNCH_PID": "\(ProcessInfo.processInfo.processIdentifier)",
        ])
    }

    static let isValid: Bool = {
        if let main = Bundle.multi?.executablePath,
           let modified = try? FileManager.default.attributesOfItem(atPath: main)[.modificationDate] as? Date,
           modified.timeIntervalSinceNow > -604800 {
            // Pass validation if within the 1-week trial period.
            return true
        }
        guard let key = defaults({ $0.string(forKey: $1) }),
              let validate = URL(string: "https://gumbs.llc/multi/license/validate?key=\(key)") else {
            // This really shouldn't fail unless user does something tricky.
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
