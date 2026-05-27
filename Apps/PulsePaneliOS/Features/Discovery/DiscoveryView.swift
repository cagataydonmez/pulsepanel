#if os(iOS)
import SwiftUI
import PulsePanelProtocol

struct DiscoveryView: View {
    @EnvironmentObject private var appState: PulsePanelAppState

    var body: some View {
        List {
            Section {
                if appState.discoveredMacs.isEmpty {
                    ContentUnavailableView(
                        "No Macs found on this network.",
                        systemImage: "network",
                        description: Text("Open PulsePanel on your Mac and keep both devices on the same Wi-Fi.")
                    )
                } else {
                    ForEach(appState.discoveredMacs) { mac in
                        Button {
                            appState.selectedMac = mac
                            appState.connectionState = .pairing
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "desktopcomputer")
                                    .foregroundStyle(.teal)
                                VStack(alignment: .leading) {
                                    Text(mac.name)
                                        .font(.headline)
                                    Text("Discovery stays on your local network.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("Pair")
                                    .font(.callout.weight(.semibold))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                Text("Choose a Mac")
            }
        }
        .navigationTitle("PulsePanel")
        .safeAreaInset(edge: .bottom) {
            Button {
                appState.startDiscovery()
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.bar)
        }
        .onAppear {
            appState.startDiscovery()
        }
    }
}
#endif
