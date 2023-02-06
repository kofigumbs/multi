import AppKit

struct Config {
    struct Schema: Decodable {
        let windowed: Bool?
        let alwaysNotify: Bool?
        let openNewWindowsWith: String?
        let openNewWindowsInBackground: Bool?
        let customCookie: [Config.Schema.Cookie]?
        let tabs: [Config.Schema.Tab]
        struct Tab: Decodable {
            let title: String
            let url: URL
            let customCss: [URL]?
            let customJs: [URL]?
            let customCookie: [Config.Schema.Cookie]?
            let basicAuthUser: String?
            let basicAuthPassword: String?
            let userAgent: String?
        }
        struct Cookie: Decodable {
            let comment: String?
            let commentURL: String?
            let discard: String?
            let domain: String?
            let expires: String?
            let maximumAge: String?
            let name: String
            let originURL: String?
            let path: String
            let port: String?
            let secure: String?
            let value: String
            let version: String?
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
        return schema.tabs.map { tab in Tab(
            title: tab.title,
            url: tab.url,
            customCss: tab.customCss ?? [],
            customJs: tab.customJs ?? [],
            customCookie: [schema.customCookie ?? [], tab.customCookie ?? []].flatMap { $0 },
            basicAuthUser: tab.basicAuthUser ?? "",
            basicAuthPassword: tab.basicAuthPassword ?? "",
            userAgent: tab.userAgent
        )}
    }()

    private static let schema: Config.Schema? = {
        guard let url = Bundle.main.url(forResource: "config", withExtension: "json"),
              let file = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(Schema.self, from: file)
    }()
}
