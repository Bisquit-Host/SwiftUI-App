import Calagopus

nonisolated private let billingSessionTokenKey = "session_token"
nonisolated private let legacyAccessTokenKey = "access_token"

nonisolated func accessToken() -> String? {
    if let sessionToken = Keychain.load(key: billingSessionTokenKey), !sessionToken.isEmpty {
        return sessionToken
    }
    
    if let legacyAccessToken = Keychain.load(key: legacyAccessTokenKey), !legacyAccessToken.isEmpty {
        return legacyAccessToken
    }
    
    Logger().error("Session token not found")
    return nil
}

nonisolated func saveBillingSessionToken(_ token: String) {
#if os(iOS) && BISQUIT_HOST_APP
    PanelSessionStore.delete()
#endif
    
    Keychain.save(token, forKey: billingSessionTokenKey)
    Keychain.delete(key: legacyAccessTokenKey)
    
#if os(iOS) && BISQUIT_HOST_APP
    Task {
        await PanelSessionCoordinator.shared.clear()
        
        do {
            _ = try await PanelSessionCoordinator.shared.credential(forceRefresh: true)
        } catch {
            Logger().error("Panel session exchange failed: \(error.localizedDescription)")
        }
    }
#endif
}

@discardableResult
nonisolated func deleteBillingSessionToken() -> Bool {
    let deletedSessionToken = Keychain.delete(key: billingSessionTokenKey)
    let deletedLegacyToken = Keychain.delete(key: legacyAccessTokenKey)
    
#if os(iOS) && BISQUIT_HOST_APP
    deletePanelSession()
#endif
    
    return deletedSessionToken || deletedLegacyToken
}
