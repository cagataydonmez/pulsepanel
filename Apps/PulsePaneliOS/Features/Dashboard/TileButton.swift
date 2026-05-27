#if os(iOS)
import SwiftUI

struct TileButton: View {
    let tile: AppTile
    let isRunning: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: tile.symbolName)
                        .font(.title2.weight(.semibold))
                    Spacer()
                    if isRunning {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(tile.title)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text(tile.kind.displayName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 142, alignment: .leading)
            .background(tileColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(tileColor.opacity(0.28), lineWidth: 1)
            )
            .foregroundStyle(tileColor)
        }
        .disabled(isRunning)
        .buttonStyle(.plain)
        .accessibilityLabel("\(tile.title), \(tile.kind.displayName)")
    }

    private var tileColor: Color {
        Color(hex: tile.accentHex) ?? .teal
    }
}

extension Color {
    init?(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        value.removePrefix("#")
        guard value.count == 6, let int = UInt64(value, radix: 16) else { return nil }
        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

private extension String {
    mutating func removePrefix(_ prefix: String) {
        guard hasPrefix(prefix) else { return }
        removeFirst(prefix.count)
    }
}
#endif
