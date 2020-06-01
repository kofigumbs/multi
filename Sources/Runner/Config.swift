import AppKit

struct Config: Decodable {
    private let title: String
    private let url: URL
    private let `private`: Bool?
    private let blocklist: Bool?

    static let tabs: [Tab] = {
        guard let path = CommandLine.arguments.last,
              let file = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONDecoder().decode([Config].self, from: file) else {
            return []
        }
        return json.map { Tab(title: $0.title, url: $0.url, private: $0.private ?? false, blocklist: $0.blocklist ?? false) }
    }()
}
