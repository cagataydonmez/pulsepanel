#if os(iOS)
import SwiftUI

@main
struct PulsePaneliOSApp: App {
    @StateObject private var appState = PulsePanelAppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
#endif
