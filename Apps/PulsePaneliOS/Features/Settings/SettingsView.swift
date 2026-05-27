#if os(iOS)
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: PulsePanelAppState

    var body: some View {
        Form {
            Section("Connected Mac") {
                LabeledContent("Name", value: appState.selectedMac?.name ?? "None")
                LabeledContent("Status", value: String(describing: appState.connectionState))
            }

            Section("Privacy") {
                Label("Commands stay on your local network.", systemImage: "lock.shield")
                Label("Trusted tokens are stored in Keychain.", systemImage: "key")
            }

            Section("Local Data") {
                Button("Clear Board", role: .destructive) {
                    appState.tiles = []
                    appState.boardStore.saveTiles([])
                }
            }
        }
        .navigationTitle("Settings")
    }
}
#endif
