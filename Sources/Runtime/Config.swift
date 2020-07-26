import AppKit

struct Config {
    struct Schema: Decodable {
        let tabs: [Config.Schema.Tab]
        struct Tab: Decodable {
            let title: String
            let url: URL
        }
    }

    static let tabs: [Tab] = {
        guard let url = Bundle.Multi.stub?.url(forResource: "config", withExtension: "json"),
              let file = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(Schema.self, from: file) else {
            return []
        }
        return config.tabs.enumerated().map { (index, tab) in
            Tab(index: index, title: tab.title, url: tab.url)
        }
    }()
}
