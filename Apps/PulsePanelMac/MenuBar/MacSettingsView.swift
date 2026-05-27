import SwiftUI

struct MacSettingsView: View {
    @EnvironmentObject private var model: MenuBarModel

    var body: some View {
        Form {
            Section("General") {
                Toggle("Local command listener", isOn: Binding(
                    get: { model.isOnline },
                    set: { $0 ? model.startServer() : model.pauseServer() }
                ))
                TextField("Mac display name", text: .constant(Host.current().localizedName ?? "Mac"))
            }

            Section("Permissions") {
                LabeledContent("Shortcuts", value: "Available when configured in Shortcuts")
                LabeledContent("Keyboard events", value: "Permission may be required")
                LabeledContent("Accessibility", value: "Future module")
            }

            Section("Privacy") {
                Text("Commands stay on your local network. Trusted devices are stored in Keychain.")
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 520, height: 420)
    }
}
