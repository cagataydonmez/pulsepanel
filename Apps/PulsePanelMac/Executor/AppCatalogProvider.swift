import AppKit
import Foundation
import PulsePanelProtocol

struct AppCatalogProvider {
    func launch(bundleId: String) async throws {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            throw ProtocolError(
                code: .appNotFound,
                message: "That app is not installed on this Mac."
            )
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        _ = try await NSWorkspace.shared.openApplication(at: url, configuration: configuration)
    }

    func installedApps() -> [InstalledApp] {
        let folders = [
            URL(fileURLWithPath: "/Applications"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
        ]

        let runningIds = Set(runningApps().map(\.bundleId))
        return folders.flatMap { folder in
            (try? FileManager.default.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: [.localizedNameKey],
                options: [.skipsHiddenFiles]
            )) ?? []
        }
        .filter { $0.pathExtension == "app" }
        .compactMap { url -> InstalledApp? in
            guard let bundle = Bundle(url: url),
                  let bundleId = bundle.bundleIdentifier else {
                return nil
            }
            let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? url.deletingPathExtension().lastPathComponent
            return InstalledApp(name: name, bundleId: bundleId, isRunning: runningIds.contains(bundleId))
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func runningApps() -> [InstalledApp] {
        NSWorkspace.shared.runningApplications.compactMap { app in
            guard let bundleId = app.bundleIdentifier else { return nil }
            return InstalledApp(
                name: app.localizedName ?? bundleId,
                bundleId: bundleId,
                isRunning: true
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
