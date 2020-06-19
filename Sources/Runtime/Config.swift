import AppKit

struct Config: Decodable {
    private let title: String
    private let url: URL
    private let `private`: Bool?
    private let blocklist: Bool?

    static let tabs: [Tab] = {
        guard let url = Bundle.Multi.stub?.url(forResource: "config", withExtension: "json"),
              let file = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode([Config].self, from: file) else {
            return []
        }
        return json.map { Tab(title: $0.title, url: $0.url, private: $0.private ?? false, blocklist: $0.blocklist ?? false) }
    }()
}
