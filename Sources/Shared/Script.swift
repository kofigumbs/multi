import Foundation

public enum Script {}
extension Script {
    public static func run(_ url: URL, environment: [ String: String ]) -> Bool {
        // Arguments and environment variables don't seem to survive across
        // calls to `open`, so we generate a script that explicitly exports
        // each variable and then `open` the generated script instead.
        guard let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first,
              let tmp = try? FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: desktop, create: true).appendingPathComponent("create-mac-app"),
              let script = """
                  #!/usr/bin/env bash
                  \(environment.map { "export MULTI_\($0.key)=\(escaped($0.value))" }.joined(separator: "\n"))
                  \(url.path) || read -p $'\\nPress Enter to exit ... '
                  """.data(using: .utf8),
              FileManager.default.createFile(
                  atPath: tmp.path,
                  contents: script,
                  attributes: [ FileAttributeKey.posixPermissions: 0o777 as Any ]) else {
            return false
        }
        let process = Process()
        process.arguments = [ "open", "-a", "Terminal", tmp.path ]
        execute(process)
        return true
    }

    private static func escaped(_ string: String) -> String {
        // Escape tricky characters using `String.init(reflecting:)` then
        // replace the enclosing `""` with `$''`.
        // <https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html>
        return "$'\(String(reflecting: string).dropFirst().dropLast())'"
    }

    private static func execute(_ process: Process) {
        let url = URL(fileURLWithPath: "/usr/bin/env")
        if #available(macOS 10.13, *) {
            process.executableURL = url
            try! process.run()
        } else {
            process.launchPath = url.path
            process.launch()
        }
    }
}
