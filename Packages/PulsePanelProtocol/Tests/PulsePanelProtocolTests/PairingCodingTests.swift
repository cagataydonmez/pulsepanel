import Foundation
import Testing
@testable import PulsePanelProtocol

@Test func pairingAcceptedRoundTrips() throws {
    let response = PairingResponse.accepted(
        mac: MacIdentity(
            id: UUID(uuidString: "A58C2E0C-FC3E-4E5D-80AD-60C9B693BE92")!,
            name: "Studio Mac",
            serviceName: "PulsePanel Studio Mac"
        ),
        trustedDeviceToken: "secret"
    )

    let data = try JSONEncoder.pulsePanel.encode(response)
    let decoded = try JSONDecoder.pulsePanel.decode(PairingResponse.self, from: data)

    #expect(decoded == response)
}

@Test func pairingRejectedRoundTrips() throws {
    let response = PairingResponse.rejected(
        reason: .wrongCode,
        message: "That code did not match."
    )

    let data = try JSONEncoder.pulsePanel.encode(response)
    let decoded = try JSONDecoder.pulsePanel.decode(PairingResponse.self, from: data)

    #expect(decoded == response)
}
