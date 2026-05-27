import CoreGraphics
import Foundation
import PulsePanelProtocol

struct HotkeySender {
    func send(modifiers: [HotkeyModifier], key: HotkeyKey) throws {
        guard let keyCode = KeyCodeMap.code(for: key.value) else {
            throw ProtocolError(code: .invalidCommand, message: "Unsupported hotkey.")
        }

        let flags = modifiers.cgFlags
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true),
              let up = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
            throw ProtocolError(code: .permissionDenied, message: "The Mac needs permission before it can receive this hotkey.")
        }
        down.flags = flags
        up.flags = flags
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }
}

private enum KeyCodeMap {
    static func code(for value: String) -> CGKeyCode? {
        let upper = value.uppercased()
        let map: [String: CGKeyCode] = [
            "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5, "Z": 6, "X": 7,
            "C": 8, "V": 9, "B": 11, "Q": 12, "W": 13, "E": 14, "R": 15,
            "Y": 16, "T": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
            "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
            "]": 30, "O": 31, "U": 32, "[": 33, "I": 34, "P": 35, "L": 37,
            "J": 38, "'": 39, "K": 40, ";": 41, "\\": 42, ",": 43, "/": 44,
            "N": 45, "M": 46, ".": 47, "`": 50, "SPACE": 49, "ESCAPE": 53
        ]
        return map[upper]
    }
}

private extension Array where Element == HotkeyModifier {
    var cgFlags: CGEventFlags {
        reduce(into: CGEventFlags()) { flags, modifier in
            switch modifier {
            case .command: flags.insert(.maskCommand)
            case .option: flags.insert(.maskAlternate)
            case .control: flags.insert(.maskControl)
            case .shift: flags.insert(.maskShift)
            }
        }
    }
}
