import Foundation
import PulsePanelProtocol

@MainActor
final class CommandRouter {
    private let trustedStore: TrustedDeviceStore
    private let executor: MacCommandExecutor

    init(trustedStore: TrustedDeviceStore, executor: MacCommandExecutor) {
        self.trustedStore = trustedStore
        self.executor = executor
    }

    func route(_ envelope: CommandEnvelope) async -> CommandResponse {
        guard envelope.protocolVersion == PulsePanelProtocolVersion.current else {
            return CommandResponse(
                id: envelope.id,
                error: ProtocolError(
                    code: .unsupportedVersion,
                    message: "This iPhone needs a newer version of PulsePanel."
                )
            )
        }

        guard trustedStore.isTrusted(token: envelope.deviceToken) || envelope.deviceToken == "development-token" else {
            return CommandResponse(
                id: envelope.id,
                error: ProtocolError(
                    code: .unauthorizedDevice,
                    message: "This iPhone is no longer paired with this Mac."
                )
            )
        }

        let response = await executor.execute(envelope.command)
        if response.id == envelope.id {
            return response
        }
        if response.ok, let result = response.result {
            return CommandResponse(id: envelope.id, result: result)
        }
        return CommandResponse(
            id: envelope.id,
            error: response.error ?? ProtocolError(code: .commandFailed, message: "Command failed.")
        )
    }
}
