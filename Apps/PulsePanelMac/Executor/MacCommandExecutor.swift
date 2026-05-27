import Foundation
import PulsePanelProtocol

@MainActor
final class MacCommandExecutor {
    private let appCatalog = AppCatalogProvider()
    private let shortcutRunner = ShortcutRunner()
    private let hotkeySender = HotkeySender()
    private let urlLauncher = URLLauncher()

    func execute(_ command: Command) async -> CommandResponse {
        let id = UUID()

        do {
            let result: CommandResult
            switch command {
            case let .launchApp(bundleId):
                try await appCatalog.launch(bundleId: bundleId)
                result = .appLaunched(bundleId: bundleId)
            case let .openURL(url):
                try await urlLauncher.open(url)
                result = .urlOpened(url: url)
            case let .runShortcut(name):
                let output = try await shortcutRunner.run(name: name)
                result = .shortcutFinished(name: name, output: output)
            case let .sendHotkey(modifiers, key):
                try hotkeySender.send(modifiers: modifiers, key: key)
                result = .hotkeySent
            case .getInstalledApps:
                result = .installedApps(appCatalog.installedApps())
            case .getRunningApps:
                result = .runningApps(appCatalog.runningApps())
            }
            return CommandResponse(id: id, result: result)
        } catch let error as ProtocolError {
            return CommandResponse(id: id, error: error)
        } catch {
            return CommandResponse(
                id: id,
                error: ProtocolError(code: .commandFailed, message: error.localizedDescription)
            )
        }
    }
}
