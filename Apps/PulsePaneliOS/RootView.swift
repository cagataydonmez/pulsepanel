#if os(iOS)
import SwiftUI
import PulsePanelProtocol

struct RootView: View {
    @EnvironmentObject private var appState: PulsePanelAppState

    var body: some View {
        NavigationStack {
            switch appState.connectionState {
            case .pairing:
                PairingView()
            case .connected, .offline, .permissionLimited, .reconnecting:
                DashboardView()
            default:
                DiscoveryView()
            }
        }
    }
}
#endif
