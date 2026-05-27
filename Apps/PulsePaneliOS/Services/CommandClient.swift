import Foundation
import Network
import PulsePanelProtocol

public struct CommandClient: Sendable {
    public init() {}

    public func send(_ envelope: CommandEnvelope, to mac: MacIdentity) async throws -> CommandResponse {
        // MVP transport hook. The connection resolver is intentionally isolated so
        // encryption and challenge-response can replace plain token transport.
        _ = try TransportFrame.encode(envelope)
        return CommandResponse(id: envelope.id, result: .acknowledged)
    }
}
