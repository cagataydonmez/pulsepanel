import Foundation
import PulsePanelProtocol

struct ShortcutRunner {
    func run(name: String) async throws -> String {
        try await runProcess(arguments: ["run", name])
    }

    func list() async throws -> String {
        try await runProcess(arguments: ["list"])
    }

    private func runProcess(arguments: [String]) async throws -> String {
        try await Task.detached {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
            process.arguments = arguments

            let output = Pipe()
            let error = Pipe()
            process.standardOutput = output
            process.standardError = error

            try process.run()
            process.waitUntilExit()

            let outputData = output.fileHandleForReading.readDataToEndOfFile()
            let errorData = error.fileHandleForReading.readDataToEndOfFile()

            if process.terminationStatus != 0 {
                let message = String(data: errorData, encoding: .utf8) ?? "The Shortcut did not finish."
                throw ProtocolError(code: .shortcutFailed, message: message)
            }

            return String(data: outputData, encoding: .utf8) ?? ""
        }.value
    }
}
