import Foundation

public struct PairingCodeAnnouncement: Codable, Hashable, Sendable {
    public let macId: UUID
    public let macName: String
    public let protocolVersion: Int
    public let expiresAt: Date

    public init(
        macId: UUID,
        macName: String,
        protocolVersion: Int = PulsePanelProtocolVersion.current,
        expiresAt: Date
    ) {
        self.macId = macId
        self.macName = macName
        self.protocolVersion = protocolVersion
        self.expiresAt = expiresAt
    }
}

public struct PairingRequest: Codable, Hashable, Sendable {
    public let code: String
    public let deviceId: UUID
    public let deviceName: String
    public let protocolVersion: Int

    public init(
        code: String,
        deviceId: UUID,
        deviceName: String,
        protocolVersion: Int = PulsePanelProtocolVersion.current
    ) {
        self.code = code
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.protocolVersion = protocolVersion
    }
}

public enum PairingRejectedReason: String, Codable, Sendable {
    case wrongCode
    case expiredCode
    case tooManyAttempts
    case pairingDisabled
    case incompatibleVersion
}

public enum PairingResponse: Codable, Hashable, Sendable {
    case accepted(mac: MacIdentity, trustedDeviceToken: String)
    case rejected(reason: PairingRejectedReason, message: String)

    private enum CodingKeys: String, CodingKey {
        case type
        case mac
        case trustedDeviceToken
        case reason
        case message
    }

    private enum ResponseType: String, Codable {
        case accepted
        case rejected
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ResponseType.self, forKey: .type)

        switch type {
        case .accepted:
            self = .accepted(
                mac: try container.decode(MacIdentity.self, forKey: .mac),
                trustedDeviceToken: try container.decode(String.self, forKey: .trustedDeviceToken)
            )
        case .rejected:
            self = .rejected(
                reason: try container.decode(PairingRejectedReason.self, forKey: .reason),
                message: try container.decode(String.self, forKey: .message)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .accepted(mac, trustedDeviceToken):
            try container.encode(ResponseType.accepted, forKey: .type)
            try container.encode(mac, forKey: .mac)
            try container.encode(trustedDeviceToken, forKey: .trustedDeviceToken)
        case let .rejected(reason, message):
            try container.encode(ResponseType.rejected, forKey: .type)
            try container.encode(reason, forKey: .reason)
            try container.encode(message, forKey: .message)
        }
    }
}
