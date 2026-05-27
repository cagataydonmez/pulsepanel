import SwiftUI

@main
struct PulsePanelMacApp: App {
    @StateObject private var model = MenuBarModel()

    var body: some Scene {
        MenuBarExtra("PulsePanel", systemImage: model.menuBarSymbol) {
            MenuBarRootView()
                .environmentObject(model)
                .frame(width: 360)
        }
        .menuBarExtraStyle(.window)

        Settings {
            MacSettingsView()
                .environmentObject(model)
        }
    }
}
