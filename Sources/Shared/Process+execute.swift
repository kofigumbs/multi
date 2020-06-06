import Foundation

extension Process {
    enum Return: Error { case nonZeroExitStatus }

    public static func execute(_ program: URL, arguments: [String]) throws {
        let process: Process
        if #available(macOS 10.13, *) {
            process = try Process.run(program, arguments: arguments)
        } else {
            process = Process.launchedProcess(launchPath: program.path, arguments: arguments)
        }
        process.waitUntilExit()
        if process.terminationStatus != 0 { throw Return.nonZeroExitStatus }
    }

    public static func execute(global: [String]) throws {
        try self.execute(URL(fileURLWithPath: "/usr/bin/env"), arguments: global)
    }
}
