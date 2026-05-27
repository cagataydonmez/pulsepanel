import Foundation

@MainActor
final class PairingCodePresenter: ObservableObject {
    @Published private(set) var activeCode: String?
    @Published private(set) var expiresAt: Date?

    func generateCode() {
        activeCode = String(format: "%06d", Int.random(in: 0...999_999))
        expiresAt = Date().addingTimeInterval(180)
    }

    func clear() {
        activeCode = nil
        expiresAt = nil
    }

    func verify(_ code: String) -> Bool {
        guard let activeCode,
              let expiresAt,
              Date() < expiresAt else {
            return false
        }
        return activeCode == code
    }
}
