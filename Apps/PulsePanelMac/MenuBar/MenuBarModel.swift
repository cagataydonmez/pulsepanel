import Foundation
import SwiftUI
import PulsePanelProtocol

@MainActor
final class MenuBarModel: ObservableObject {
    @Published var isOnline = false
    @Published var isPairing = false
    @Published var permissionNeeded = false
    @Published var recentEvents: [CommandActivity] = []

    let pairingPresenter = PairingCodePresenter()
    let trustedStore = TrustedDeviceStore(service: "com.pulsepanel.mac")
    let executor = MacCommandExecutor()
    private lazy var router = CommandRouter(trustedStore: trustedStore, executor: executor)
    private var server: BonjourServer?

    var menuBarSymbol: String {
        if permissionNeeded { return "exclamationmark.triangle" }
        if isPairing { return "lock.badge.clock" }
        return isOnline ? "rectangle.connected.to.line.below" : "rectangle.slash"
    }

    init() {
        startServer()
    }

    func startServer() {
        guard server == nil else { return }
        let server = BonjourServer(router: router)
        self.server = server
        do {
            try server.start()
            isOnline = true
        } catch {
            isOnline = false
            record("Server failed to start", result: "Failed")
        }
    }

    func pauseServer() {
        server?.stop()
        server = nil
        isOnline = false
    }

    func showPairingCode() {
        pairingPresenter.generateCode()
        isPairing = true
    }

    func stopPairing() {
        pairingPresenter.clear()
        isPairing = false
    }

    func record(_ command: String, result: String) {
        recentEvents.insert(CommandActivity(command: command, result: result), at: 0)
        recentEvents = Array(recentEvents.prefix(20))
    }
}

struct CommandActivity: Identifiable, Hashable {
    let id = UUID()
    let date = Date()
    let command: String
    let result: String
}
