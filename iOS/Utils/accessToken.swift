import Calagopus

private let billingSessionTokenKey = "session_token"
private let legacyAccessTokenKey = "access_token"

func accessToken() -> String? {
    if let sessionToken = Keychain.load(key: billingSessionTokenKey), !sessionToken.isEmpty {
        return sessionToken
    }
    
    if let legacyAccessToken = Keychain.load(key: legacyAccessTokenKey), !legacyAccessToken.isEmpty {
        return legacyAccessToken
    }
    
    Logger().error("Session token not found")
    return nil
}

func saveBillingSessionToken(_ token: String) {
    Keychain.save(token, forKey: billingSessionTokenKey)
    Keychain.delete(key: legacyAccessTokenKey)
}

@discardableResult
func deleteBillingSessionToken() -> Bool {
    let deletedSessionToken = Keychain.delete(key: billingSessionTokenKey)
    let deletedLegacyToken = Keychain.delete(key: legacyAccessTokenKey)
    
    return deletedSessionToken || deletedLegacyToken
}
