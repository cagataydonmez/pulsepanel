import SwiftUI

struct MenuBarRootView: View {
    @EnvironmentObject private var model: MenuBarModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            Button {
                model.showPairingCode()
            } label: {
                Label("Show Pairing Code", systemImage: "lock.badge.clock")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if model.isPairing, let code = model.pairingPresenter.activeCode {
                PairingCodeView(code: code)
            }

            Divider()

            devicesSection
            activitySection

            HStack {
                Button(model.isOnline ? "Pause Server" : "Start Server") {
                    model.isOnline ? model.pauseServer() : model.startServer()
                }
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(18)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: model.menuBarSymbol)
                .font(.title2)
                .foregroundStyle(model.isOnline ? .teal : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("PulsePanel")
                    .font(.headline)
                Text(model.isOnline ? "Online on local network" : "Server paused")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var devicesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Paired Devices")
                .font(.subheadline.weight(.semibold))
            if model.trustedStore.devices.isEmpty {
                Text("No paired iPhones yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.trustedStore.devices) { device in
                    HStack {
                        Image(systemName: "iphone")
                        Text(device.name)
                        Spacer()
                        Button("Revoke") {
                            model.trustedStore.revoke(device)
                        }
                    }
                }
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Commands")
                .font(.subheadline.weight(.semibold))
            if model.recentEvents.isEmpty {
                Text("No local commands yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.recentEvents.prefix(5)) { event in
                    HStack {
                        Text(event.command)
                            .lineLimit(1)
                        Spacer()
                        Text(event.result)
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
            }
        }
    }
}
