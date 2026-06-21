#if os(iOS)
import Calagopus

enum BillingIntentAccessToken {
    nonisolated static func load() -> String? {
        if let sessionToken = Keychain.load(key: "session_token"), !sessionToken.isEmpty {
            return sessionToken
        }
        
        if let legacyAccessToken = Keychain.load(key: "access_token"), !legacyAccessToken.isEmpty {
            return legacyAccessToken
        }
        
        return nil
    }
}
#endif
