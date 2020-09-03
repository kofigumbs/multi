import AppKit

struct Config {
    struct Schema: Decodable {
        let sideBySide: Bool?
        let alwaysNotify: Bool?
        let openNewWindowsWith: String?
        let tabs: [Config.Schema.Tab]
        struct Tab: Decodable {
            let title: String
            let url: URL
            let customCss: [URL]?
        }
    }

    static let sideBySide: Bool = {
        return schema?.sideBySide ?? false
    }()

    static let alwaysNotify: Bool = {
        return schema?.alwaysNotify ?? false
    }()

    static let openNewWindowsWith: String? = {
        return schema?.openNewWindowsWith
    }()

    static let tabs: [Tab] = {
        guard let schema = schema else { return [] }
        var tabs = schema.tabs.map { Tab(title: $0.title, url: $0.url, customCss: $0.customCss ?? []) }
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
