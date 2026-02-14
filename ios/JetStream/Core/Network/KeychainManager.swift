import Foundation
import Security

final class KeychainManager {
    private let serviceName = "com.iamsohail.JetStream"

    enum KeychainKey: String {
        case accessToken
        case refreshToken
    }

    func save(_ value: String, for key: KeychainKey) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
        ]

        SecItemDelete(query as CFDictionary)

        var newItem = query
        newItem[kSecValueData as String] = data
        SecItemAdd(newItem as CFDictionary, nil)
    }

    func get(_ key: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(_ key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
        ]
        SecItemDelete(query as CFDictionary)
    }

    func getAccessToken() -> String? {
        get(.accessToken)
    }

    func getRefreshToken() -> String? {
        get(.refreshToken)
    }

    func saveTokens(access: String, refresh: String) {
        save(access, for: .accessToken)
        save(refresh, for: .refreshToken)
    }

    func clearTokens() {
        delete(.accessToken)
        delete(.refreshToken)
    }
}
