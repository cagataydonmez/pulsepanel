import Foundation

public enum ConnectionState: String, Codable, Sendable {
    case discovered
    case pairing
    case paired
    case connecting
    case connected
    case reconnecting
    case offline
    case permissionLimited
    case incompatible
}

public struct MacIdentity: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let serviceName: String
    public let protocolVersion: Int

    public init(
        id: UUID,
        name: String,
        serviceName: String,
        protocolVersion: Int = PulsePanelProtocolVersion.current
    ) {
        self.id = id
        self.name = name
        self.serviceName = serviceName
        self.protocolVersion = protocolVersion
    }
}

public struct TrustedDevice: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let token: String
    public let pairedAt: Date
    public let lastSeenAt: Date?

    public init(
        id: UUID,
        name: String,
        token: String,
        pairedAt: Date = Date(),
        lastSeenAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.token = token
        self.pairedAt = pairedAt
        self.lastSeenAt = lastSeenAt
    }
}
