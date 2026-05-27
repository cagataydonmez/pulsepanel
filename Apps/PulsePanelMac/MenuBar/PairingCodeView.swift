import SwiftUI

struct PairingCodeView: View {
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(code)
                .font(.system(size: 42, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .accessibilityLabel("Pairing code \(code)")
            Text("Enter this code on your iPhone. This code expires in 3 minutes.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }
}
