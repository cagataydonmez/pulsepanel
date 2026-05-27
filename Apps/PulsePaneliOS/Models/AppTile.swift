import Foundation
import PulsePanelProtocol

public enum TileKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case app
    case website
    case shortcut
    case hotkey

    public var id: String { rawValue }
}

public struct AppTile: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var title: String
    public var kind: TileKind
    public var symbolName: String
    public var accentHex: String
    public var requiresConfirmation: Bool
    public var command: Command

    public init(
        id: UUID = UUID(),
        title: String,
        kind: TileKind,
        symbolName: String,
        accentHex: String = "#0D9488",
        requiresConfirmation: Bool = false,
        command: Command
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.symbolName = symbolName
        self.accentHex = accentHex
        self.requiresConfirmation = requiresConfirmation
        self.command = command
    }

    public static let samples: [AppTile] = [
        AppTile(
            title: "Safari",
            kind: .app,
            symbolName: "safari",
            command: .launchApp(bundleId: "com.apple.Safari")
        ),
        AppTile(
            title: "Open Docs",
            kind: .website,
            symbolName: "globe",
            accentHex: "#14B8A6",
            command: .openURL(url: URL(string: "https://developer.apple.com")!)
        ),
        AppTile(
            title: "Focus Mode",
            kind: .shortcut,
            symbolName: "sparkles",
            accentHex: "#F97316",
            command: .runShortcut(name: "Focus Mode")
        )
    ]
}

public extension TileKind {
    var displayName: String {
        switch self {
        case .app: "App"
        case .website: "Website"
        case .shortcut: "Shortcut"
        case .hotkey: "Hotkey"
        }
    }

    var defaultSymbolName: String {
        switch self {
        case .app: "app"
        case .website: "globe"
        case .shortcut: "sparkles"
        case .hotkey: "keyboard"
        }
    }
}
