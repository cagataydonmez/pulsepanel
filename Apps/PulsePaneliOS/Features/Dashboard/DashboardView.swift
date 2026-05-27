#if os(iOS)
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: PulsePanelAppState
    @State private var showingEditor = false
    @State private var editingTile: AppTile?

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if appState.tiles.isEmpty {
                    ContentUnavailableView(
                        "Add your first tile",
                        systemImage: "square.grid.2x2",
                        description: Text("Create a local command for this Mac.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 320)
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(appState.tiles) { tile in
                            TileButton(
                                tile: tile,
                                isRunning: appState.runningTileIds.contains(tile.id)
                            ) {
                                appState.run(tile: tile)
                            }
                            .contextMenu {
                                Button("Edit") {
                                    editingTile = tile
                                }
                                Button("Duplicate") {
                                    var copy = tile
                                    copy.id = UUID()
                                    copy.title += " Copy"
                                    appState.addTile(copy)
                                }
                                Button("Delete", role: .destructive) {
                                    appState.deleteTile(tile)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                showingEditor = true
            } label: {
                Label("Add Tile", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.bar)
        }
        .sheet(isPresented: $showingEditor) {
            TileEditorView(tile: nil)
        }
        .sheet(item: $editingTile) { tile in
            TileEditorView(tile: tile)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(appState.selectedMac?.name ?? "No Mac Selected")
                    .font(.title3.weight(.semibold))
                Label(statusText, systemImage: "circle.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(statusColor)
            }
            Spacer()
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape")
                    .font(.title3)
            }
            .accessibilityLabel("Settings")
        }
    }

    private var statusText: String {
        switch appState.connectionState {
        case .connected: "Connected"
        case .reconnecting: "Reconnecting"
        case .permissionLimited: "Permission Needed"
        case .offline: "Offline"
        default: "Local Network"
        }
    }

    private var statusColor: Color {
        switch appState.connectionState {
        case .connected: .teal
        case .permissionLimited: .orange
        case .offline: .red
        default: .secondary
        }
    }
}
#endif
