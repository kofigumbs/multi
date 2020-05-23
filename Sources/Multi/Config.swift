import Foundation

struct Config {
    private struct BadJson: Error {}

    let title: String
    let url: URL

    private static func error(_ message: String) -> [Browser] {
        let html = """
            <!DOCTYPE html>
            <h1>Invalid configuration file</h1>
            <pre><code>\(message)</code></pre>
        """
        return [ Browser("Error", html: html) ]
    }

    static let browsers: [Browser] = {
        guard let path = Bundle.main.path(forResource: "config", ofType: "json"),
              let file = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return error("File does not exist")
        }
        guard let json = try? decode(file) else {
            return error("Required format is [{ title: String, url: String }]")
        }
        return json.isEmpty 
            ? error("JSON object is empty")
            : json.map { Browser($0.title, url: $0.url) }
    }()

    private static func decode(_ data: Data) throws -> [Config] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String:String]] else {
            throw BadJson()
        }
        return try json.map { dict in
            guard let title = dict["title"],
                  let rawUrl = dict["url"],
                  let url = URL(string: rawUrl) else {
                throw BadJson()
            }
            return Config(title: title, url: url)
        }
    }
}
