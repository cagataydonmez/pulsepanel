#if os(iOS)
import SwiftUI
import PulsePanelProtocol

struct TileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: PulsePanelAppState

    @State private var draft: AppTile
    @State private var urlString = "https://"
    @State private var shortcutName = ""
    @State private var bundleId = ""
    @State private var hotkey = "P"

    init(tile: AppTile?) {
        let initial = tile ?? AppTile(
            title: "",
            kind: .website,
            symbolName: TileKind.website.defaultSymbolName,
            command: .openURL(url: URL(string: "https://example.com")!)
        )
        _draft = State(initialValue: initial)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Tile Type", selection: $draft.kind) {
                        ForEach(TileKind.allCases) { kind in
                            Label(kind.displayName, systemImage: kind.defaultSymbolName)
                                .tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: draft.kind) { _, kind in
                        draft.symbolName = kind.defaultSymbolName
                    }
                }

                Section("Command") {
                    TextField("Title", text: $draft.title)

                    switch draft.kind {
                    case .app:
                        TextField("Bundle ID", text: $bundleId)
                            .textInputAutocapitalization(.never)
                    case .website:
                        TextField("URL", text: $urlString)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                    case .shortcut:
                        TextField("Shortcut name", text: $shortcutName)
                    case .hotkey:
                        TextField("Key", text: $hotkey)
                            .textInputAutocapitalization(.characters)
                    }
                }

                Section("Appearance") {
                    TextField("SF Symbol", text: $draft.symbolName)
                    Picker("Accent", selection: $draft.accentHex) {
                        ForEach(["#0D9488", "#14B8A6", "#F97316", "#3B82F6", "#22C55E"], id: \.self) { hex in
                            Text(hex).tag(hex)
                        }
                    }
                    Toggle("Require confirmation", isOn: $draft.requiresConfirmation)
                }
            }
            .navigationTitle(draft.title.isEmpty ? "Add Tile" : "Edit Tile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        switch draft.kind {
        case .app:
            draft.command = .launchApp(bundleId: bundleId.isEmpty ? "com.apple.Safari" : bundleId)
        case .website:
            draft.command = .openURL(url: URL(string: urlString) ?? URL(string: "https://example.com")!)
        case .shortcut:
            draft.command = .runShortcut(name: shortcutName.isEmpty ? draft.title : shortcutName)
        case .hotkey:
            draft.command = .sendHotkey(modifiers: [.command], key: HotkeyKey(hotkey))
        }

        if appState.tiles.contains(where: { $0.id == draft.id }) {
            appState.updateTile(draft)
        } else {
            appState.addTile(draft)
        }
        dismiss()
    }
}
#endif
