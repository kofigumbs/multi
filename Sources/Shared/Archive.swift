import Foundation

struct Archive {
    enum Error: Swift.Error {
        case alreadyExists, cannotWriteFile(URL)
    }

    let name: String
    let app: URL
    let stub: URL
    let plist: Data
    let config: Data

    var contents: URL { app.appendingPathComponent("Contents", isDirectory: true) }
    var resources: URL { contents.appendingPathComponent("Resources", isDirectory: true) }

    func create() throws {
        if FileManager.default.fileExists(atPath: app.path) {
            throw Error.alreadyExists
        }
        try FileManager.default.createDirectory(
            at: app,
            withIntermediateDirectories: false,
            attributes: [FileAttributeKey.posixPermissions: 0o777 as Any]
        )
        try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
        try update()
    }

    func update() throws {
        try FileManager.default.copyItem(at: stub, to: app.appendingPathComponent("Stub"))
        try ensureFile(at: contents.appendingPathComponent("Info.plist"), contents: plist)
        try ensureFile(at: resources.appendingPathComponent("config.json"), contents: config)
    }

    private func ensureFile(at: URL, contents: Data) throws {
        guard FileManager.default.createFile(atPath: at.path, contents: contents) else {
            throw Error.cannotWriteFile(at)
        }
    }
}
