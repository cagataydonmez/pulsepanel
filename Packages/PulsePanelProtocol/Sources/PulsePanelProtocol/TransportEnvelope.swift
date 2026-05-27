import Foundation

public enum PulsePanelProtocolVersion {
    public static let current = 1
}

public struct CommandEnvelope: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let protocolVersion: Int
    public let issuedAt: Date
    public let deviceToken: String
    public let command: Command

    public init(
        id: UUID = UUID(),
        protocolVersion: Int = PulsePanelProtocolVersion.current,
        issuedAt: Date = Date(),
        deviceToken: String,
        command: Command
    ) {
        self.id = id
        self.protocolVersion = protocolVersion
        self.issuedAt = issuedAt
        self.deviceToken = deviceToken
        self.command = command
    }
}

public struct CommandResponse: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let ok: Bool
    public let result: CommandResult?
    public let error: ProtocolError?

    public init(id: UUID, result: CommandResult) {
        self.id = id
        self.ok = true
        self.result = result
        self.error = nil
    }

    public init(id: UUID, error: ProtocolError) {
        self.id = id
        self.ok = false
        self.result = nil
        self.error = error
    }
}

public struct TransportFrame {
    public static func encode<T: Encodable>(_ value: T, using encoder: JSONEncoder = .pulsePanel) throws -> Data {
        let payload = try encoder.encode(value)
        var length = UInt32(payload.count).bigEndian
        var frame = Data(bytes: &length, count: MemoryLayout<UInt32>.size)
        frame.append(payload)
        return frame
    }

    public static func decodePayloadLength(from header: Data) -> Int? {
        guard header.count == MemoryLayout<UInt32>.size else { return nil }
        let value = header.withUnsafeBytes { buffer in
            buffer.load(as: UInt32.self)
        }
        return Int(UInt32(bigEndian: value))
    }
}

public extension JSONEncoder {
    static var pulsePanel: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}

public extension JSONDecoder {
    static var pulsePanel: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
