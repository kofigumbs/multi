import AppKit

struct Config {
    struct Schema: Decodable {
        let sideBySide: Bool?
        let tabs: [Config.Schema.Tab]
        struct Tab: Decodable {
            let title: String
            let url: URL
        }
    }

    static let sideBySide: Bool = {
        return schema?.sideBySide ?? false
    }()

    static let tabs: [Tab] = {
        guard let schema = schema else { return [] }
        return schema.tabs.enumerated().map { (index, tab) in
            Tab(index: index, title: tab.title, url: tab.url)
        }
    }()

    private static let schema: Config.Schema? = {
        guard let url = Bundle.Multi.stub?.url(forResource: "config", withExtension: "json"),
              let file = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(Schema.self, from: file)
    }()
}
