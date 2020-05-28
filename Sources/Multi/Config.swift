import Foundation

struct Config: Decodable {
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
        guard let json = try? JSONDecoder().decode([Config].self, from: file) else {
            return error("Required format is [{ title: String, url: String }]")
        }
        return json.isEmpty 
            ? error("JSON object is empty")
            : json.map { Browser($0.title, url: $0.url) }
    }()
}
