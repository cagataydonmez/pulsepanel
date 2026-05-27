import Foundation

public enum HotkeyModifier: String, Codable, CaseIterable, Sendable, Identifiable {
    case command
    case option
    case control
    case shift

    public var id: String { rawValue }
}

public struct HotkeyKey: Codable, Hashable, Sendable, Identifiable {
    public var id: String { value }
    public let value: String

    public init(_ value: String) {
        self.value = value
    }
}

public struct InstalledApp: Codable, Hashable, Sendable, Identifiable {
    public var id: String { bundleId }
    public let name: String
    public let bundleId: String
    public let isRunning: Bool

    public init(name: String, bundleId: String, isRunning: Bool = false) {
        self.name = name
        self.bundleId = bundleId
        self.isRunning = isRunning
    }
}

public enum Command: Codable, Hashable, Sendable {
    case launchApp(bundleId: String)
    case openURL(url: URL)
    case runShortcut(name: String)
    case sendHotkey(modifiers: [HotkeyModifier], key: HotkeyKey)
    case getInstalledApps
    case getRunningApps

    private enum CodingKeys: String, CodingKey {
        case type
        case bundleId
        case url
        case name
        case modifiers
        case key
    }

    private enum CommandType: String, Codable {
        case launchApp
        case openURL
        case runShortcut
        case sendHotkey
        case getInstalledApps
        case getRunningApps
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CommandType.self, forKey: .type)

        switch type {
        case .launchApp:
            self = .launchApp(bundleId: try container.decode(String.self, forKey: .bundleId))
        case .openURL:
            self = .openURL(url: try container.decode(URL.self, forKey: .url))
        case .runShortcut:
            self = .runShortcut(name: try container.decode(String.self, forKey: .name))
        case .sendHotkey:
            self = .sendHotkey(
                modifiers: try container.decode([HotkeyModifier].self, forKey: .modifiers),
                key: try container.decode(HotkeyKey.self, forKey: .key)
            )
        case .getInstalledApps:
            self = .getInstalledApps
        case .getRunningApps:
            self = .getRunningApps
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .launchApp(bundleId):
            try container.encode(CommandType.launchApp, forKey: .type)
            try container.encode(bundleId, forKey: .bundleId)
        case let .openURL(url):
            try container.encode(CommandType.openURL, forKey: .type)
            try container.encode(url, forKey: .url)
        case let .runShortcut(name):
            try container.encode(CommandType.runShortcut, forKey: .type)
            try container.encode(name, forKey: .name)
        case let .sendHotkey(modifiers, key):
            try container.encode(CommandType.sendHotkey, forKey: .type)
            try container.encode(modifiers, forKey: .modifiers)
            try container.encode(key, forKey: .key)
        case .getInstalledApps:
            try container.encode(CommandType.getInstalledApps, forKey: .type)
        case .getRunningApps:
            try container.encode(CommandType.getRunningApps, forKey: .type)
        }
    }
}

public enum CommandResult: Codable, Hashable, Sendable {
    case acknowledged
    case appLaunched(bundleId: String)
    case urlOpened(url: URL)
    case shortcutFinished(name: String, output: String)
    case hotkeySent
    case installedApps([InstalledApp])
    case runningApps([InstalledApp])

    private enum CodingKeys: String, CodingKey {
        case type
        case bundleId
        case url
        case name
        case output
        case apps
    }

    private enum ResultType: String, Codable {
        case acknowledged
        case appLaunched
        case urlOpened
        case shortcutFinished
        case hotkeySent
        case installedApps
        case runningApps
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ResultType.self, forKey: .type)

        switch type {
        case .acknowledged:
            self = .acknowledged
        case .appLaunched:
            self = .appLaunched(bundleId: try container.decode(String.self, forKey: .bundleId))
        case .urlOpened:
            self = .urlOpened(url: try container.decode(URL.self, forKey: .url))
        case .shortcutFinished:
            self = .shortcutFinished(
                name: try container.decode(String.self, forKey: .name),
                output: try container.decode(String.self, forKey: .output)
            )
        case .hotkeySent:
            self = .hotkeySent
        case .installedApps:
            self = .installedApps(try container.decode([InstalledApp].self, forKey: .apps))
        case .runningApps:
            self = .runningApps(try container.decode([InstalledApp].self, forKey: .apps))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .acknowledged:
            try container.encode(ResultType.acknowledged, forKey: .type)
        case let .appLaunched(bundleId):
            try container.encode(ResultType.appLaunched, forKey: .type)
            try container.encode(bundleId, forKey: .bundleId)
        case let .urlOpened(url):
            try container.encode(ResultType.urlOpened, forKey: .type)
            try container.encode(url, forKey: .url)
        case let .shortcutFinished(name, output):
            try container.encode(ResultType.shortcutFinished, forKey: .type)
            try container.encode(name, forKey: .name)
            try container.encode(output, forKey: .output)
        case .hotkeySent:
            try container.encode(ResultType.hotkeySent, forKey: .type)
        case let .installedApps(apps):
            try container.encode(ResultType.installedApps, forKey: .type)
            try container.encode(apps, forKey: .apps)
        case let .runningApps(apps):
            try container.encode(ResultType.runningApps, forKey: .type)
            try container.encode(apps, forKey: .apps)
        }
    }
}
