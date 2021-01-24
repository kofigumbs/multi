import AppKit

struct Config {
    struct Schema: Decodable {
        let windowed: Bool?
        let alwaysNotify: Bool?
        let openNewWindowsWith: String?
        let openNewWindowsInBackground: Bool?
        let tabs: [Config.Schema.Tab]
        struct Tab: Decodable {
            let title: String
            let url: URL
            let customCss: [URL]?
            let customJs: [URL]?
            let basicAuthUser: String?
            let basicAuthPassword: String?
            let userAgent: String?
        }
    }

    static let windowed: Bool = {
        return schema?.windowed ?? false
    }()

    static let alwaysNotify: Bool = {
        return schema?.alwaysNotify ?? false
    }()

    static let openNewWindowsWith: String? = {
        return schema?.openNewWindowsWith
    }()

    static let openNewWindowsInBackground: Bool = {
        return schema?.openNewWindowsInBackground ?? false
    }()

    static let tabs: [Tab] = {
        guard let schema = schema else { return [] }
        var tabs = schema.tabs.map { tab in Tab(
            title: tab.title,
            url: tab.url,
            customCss: tab.customCss ?? [],
            customJs: tab.customJs ?? [],
            basicAuthUser: tab.basicAuthUser ?? "",
            basicAuthPassword: tab.basicAuthPassword ?? "",
            userAgent: tab.userAgent ?? "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"
        )}
        if !tabs.isEmpty && !License.isValid {
            tabs.insert(Tab(license: ()), at: 0)
        }
        return tabs
    }()

    private static let schema: Config.Schema? = {
        guard let url = Bundle.main.url(forResource: "config", withExtension: "json"),
              let file = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(Schema.self, from: file)
    }()
}
