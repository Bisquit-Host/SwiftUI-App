import Foundation
import Security

nonisolated struct AppAttestKeychain {
    private let service = "host.bisquit.Bisquit-host.app-attest"
    private let account = "primary-key-id"
    
    func loadKeyID() throws -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw AttestError.keychainFailed(status)
        }
        
        guard
            let data = item as? Data,
            let keyID = String(data: data, encoding: .utf8),
            !keyID.isEmpty
        else {
            throw AttestError.invalidResponse
        }
        
        return keyID
    }
    
    func saveKeyID(_ keyID: String) throws {
        guard let data = keyID.data(using: .utf8) else {
            throw AttestError.invalidResponse
        }
        
        var addQuery = baseQuery
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let updateStatus = SecItemUpdate(
                baseQuery as CFDictionary,
                [kSecValueData as String: data] as CFDictionary
            )
            
            guard updateStatus == errSecSuccess else {
                throw AttestError.keychainFailed(updateStatus)
            }
            
            return
        }
        
        guard status == errSecSuccess else {
            throw AttestError.keychainFailed(status)
        }
    }
    
    func deleteKeyID() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AttestError.keychainFailed(status)
        }
    }
    
    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
