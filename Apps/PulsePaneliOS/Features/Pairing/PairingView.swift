#if os(iOS)
import SwiftUI

struct PairingView: View {
    @EnvironmentObject private var appState: PulsePanelAppState
    @State private var code = ""
    @State private var isVerifying = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Image(systemName: "lock.badge.clock")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.teal)
                Text(appState.selectedMac?.name ?? "Mac")
                    .font(.title2.weight(.semibold))
                Text("Enter the 6-digit code shown on your Mac.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    Text(character(at: index))
                        .font(.title.monospacedDigit().weight(.semibold))
                        .frame(width: 44, height: 54)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(index == code.count ? Color.teal : Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .accessibilityLabel("Pairing code")

            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .opacity(0.01)
                .frame(width: 1, height: 1)
                .onChange(of: code) { _, newValue in
                    code = String(newValue.filter(\.isNumber).prefix(6))
                    if code.count == 6 {
                        verify()
                    }
                }

            if isVerifying {
                ProgressView("Verifying")
            }

            Button("Choose another Mac") {
                appState.connectionState = .discovered
            }
            .buttonStyle(.borderless)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Pair Mac")
        .onAppear {
            focused = true
        }
    }

    private func character(at index: Int) -> String {
        guard index < code.count else { return "" }
        let stringIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[stringIndex])
    }

    private func verify() {
        guard !isVerifying, let mac = appState.selectedMac else { return }
        isVerifying = true
        appState.keychainStore.saveToken("development-token", account: mac.id.uuidString)

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            isVerifying = false
            appState.connectionState = .connected
        }
    }
}
#endif
