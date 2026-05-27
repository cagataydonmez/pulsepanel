import Foundation
import Network
import PulsePanelProtocol

final class BonjourServer: @unchecked Sendable {
    private let router: CommandRouter
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "PulsePanel.BonjourServer")

    init(router: CommandRouter) {
        self.router = router
    }

    func start() throws {
        let listener = try NWListener(using: .tcp)
        let name = Host.current().localizedName ?? UUID().uuidString
        listener.service = NWListener.Service(name: name, type: "_pulsepanel._tcp")
        listener.newConnectionHandler = { [weak self] connection in
            connection.start(queue: self?.queue ?? .global())
            self?.receiveHeader(on: connection)
        }
        listener.start(queue: queue)
        self.listener = listener
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func receiveHeader(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] data, _, isComplete, error in
            guard let self, let data, error == nil, !isComplete,
                  let length = TransportFrame.decodePayloadLength(from: data) else {
                connection.cancel()
                return
            }
            self.receivePayload(length: length, on: connection)
        }
    }

    private func receivePayload(length: Int, on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: length, maximumLength: length) { [weak self] data, _, _, error in
            guard let self, let data, error == nil else {
                connection.cancel()
                return
            }

            Task { @MainActor in
                let response: CommandResponse
                do {
                    let envelope = try JSONDecoder.pulsePanel.decode(CommandEnvelope.self, from: data)
                    response = await self.router.route(envelope)
                } catch {
                    response = CommandResponse(
                        id: UUID(),
                        error: ProtocolError(code: .invalidFrame, message: "Command frame was invalid.")
                    )
                }

                do {
                    let frame = try TransportFrame.encode(response)
                    connection.send(content: frame, completion: .contentProcessed { _ in
                        self.receiveHeader(on: connection)
                    })
                } catch {
                    connection.cancel()
                }
            }
        }
    }
}
