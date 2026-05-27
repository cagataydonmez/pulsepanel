#if os(iOS)
import Foundation
import Observation
import SwiftUI
import PulsePanelProtocol

@MainActor
final class PulsePanelAppState: ObservableObject {
    @Published var discoveredMacs: [MacIdentity] = []
    @Published var selectedMac: MacIdentity?
    @Published var connectionState: ConnectionState = .offline
    @Published var tiles: [AppTile] = []
    @Published var lastError: ProtocolError?
    @Published var runningTileIds: Set<UUID> = []

    let boardStore = BoardStore()
    let keychainStore = KeychainStore(service: "com.pulsepanel.ios")
    let browser = BonjourBrowser()
    let commandClient = CommandClient()

    init() {
        tiles = boardStore.loadTiles()
        browser.onUpdate = { [weak self] macs in
            Task { @MainActor in
                self?.discoveredMacs = macs
                if self?.selectedMac == nil {
                    self?.selectedMac = macs.first
                    self?.connectionState = macs.isEmpty ? .offline : .discovered
                }
            }
        }
    }

    func startDiscovery() {
        browser.start()
    }

    func stopDiscovery() {
        browser.stop()
    }

    func addTile(_ tile: AppTile) {
        tiles.append(tile)
        boardStore.saveTiles(tiles)
    }

    func updateTile(_ tile: AppTile) {
        guard let index = tiles.firstIndex(where: { $0.id == tile.id }) else { return }
        tiles[index] = tile
        boardStore.saveTiles(tiles)
    }

    func deleteTile(_ tile: AppTile) {
        tiles.removeAll { $0.id == tile.id }
        boardStore.saveTiles(tiles)
    }

    func run(tile: AppTile) {
        guard let selectedMac else {
            lastError = ProtocolError(code: .macUnavailable, message: "This Mac is offline.")
            return
        }
        guard !runningTileIds.contains(tile.id) else { return }

        let token = keychainStore.loadToken(account: selectedMac.id.uuidString) ?? "development-token"
        runningTileIds.insert(tile.id)
        lastError = nil

        Task {
            do {
                _ = try await commandClient.send(
                    CommandEnvelope(deviceToken: token, command: tile.command),
                    to: selectedMac
                )
                await MainActor.run {
                    runningTileIds.remove(tile.id)
                    connectionState = .connected
                }
            } catch {
                await MainActor.run {
                    runningTileIds.remove(tile.id)
                    lastError = ProtocolError(
                        code: .commandFailed,
                        message: "Command failed.",
                        recoverySuggestion: "Check that PulsePanel is open on your Mac."
                    )
                }
            }
        }
    }
}
#endif
