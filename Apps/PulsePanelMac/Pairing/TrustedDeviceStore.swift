import Foundation
import PulsePanelProtocol
import Security

@MainActor
final class TrustedDeviceStore: ObservableObject {
    @Published private(set) var devices: [TrustedDevice] = []
    private let service: String
    private let defaultsKey = "pulsepanel.trustedDevices.v1"

    init(service: String) {
        self.service = service
        loadDevices()
    }

    func trustDevice(id: UUID, name: String, token: String) {
        saveToken(token, account: id.uuidString)
        let device = TrustedDevice(id: id, name: name, token: token)
        devices.removeAll { $0.id == id }
        devices.append(device)
        persistDevices()
    }

    func isTrusted(token: String) -> Bool {
        devices.contains { loadToken(account: $0.id.uuidString) == token }
    }

    func revoke(_ device: TrustedDevice) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: device.id.uuidString
        ]
        SecItemDelete(query as CFDictionary)
        devices.removeAll { $0.id == device.id }
        persistDevices()
    }

    private func loadDevices() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder.pulsePanel.decode([TrustedDevice].self, from: data) else {
            devices = []
            return
        }
        devices = decoded
    }

    private func persistDevices() {
        guard let data = try? JSONEncoder.pulsePanel.encode(devices) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private func saveToken(_ token: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)

        var item = query
        item[kSecValueData as String] = Data(token.utf8)
        SecItemAdd(item as CFDictionary, nil)
    }

    private func loadToken(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
