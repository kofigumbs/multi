import Foundation

extension Process {
    func execute(_ url: URL) throws {
        if #available(macOS 10.13, *) {
            process.executableURL = url
            try process.run()
        } else {
            process.launchPath = url.absoluteString
            process.launch()
        }
    }
}
