import Foundation
import Testing
@testable import PulsePanelProtocol

@Test func commandEnvelopeRoundTrips() throws {
    let envelope = CommandEnvelope(
        id: UUID(uuidString: "6C3A0966-07F5-4E72-A79E-01077DF48E20")!,
        issuedAt: Date(timeIntervalSince1970: 1_772_000_000),
        deviceToken: "trusted-token",
        command: .sendHotkey(modifiers: [.command, .shift], key: HotkeyKey("P"))
    )

    let data = try JSONEncoder.pulsePanel.encode(envelope)
    let decoded = try JSONDecoder.pulsePanel.decode(CommandEnvelope.self, from: data)

    #expect(decoded == envelope)
}

@Test func commandResultRoundTripsApps() throws {
    let response = CommandResponse(
        id: UUID(uuidString: "F56D58E1-AC62-4C59-A475-2E2D9FC6020D")!,
        result: .installedApps([
            InstalledApp(name: "Safari", bundleId: "com.apple.Safari"),
            InstalledApp(name: "Shortcuts", bundleId: "com.apple.shortcuts", isRunning: true)
        ])
    )

    let data = try JSONEncoder.pulsePanel.encode(response)
    let decoded = try JSONDecoder.pulsePanel.decode(CommandResponse.self, from: data)

    #expect(decoded == response)
}

@Test func transportFramePrefixesPayloadLength() throws {
    let envelope = CommandEnvelope(deviceToken: "token", command: .getRunningApps)
    let frame = try TransportFrame.encode(envelope)
    let header = frame.prefix(4)
    let payload = frame.dropFirst(4)

    #expect(TransportFrame.decodePayloadLength(from: Data(header)) == payload.count)
    _ = try JSONDecoder.pulsePanel.decode(CommandEnvelope.self, from: Data(payload))
}
