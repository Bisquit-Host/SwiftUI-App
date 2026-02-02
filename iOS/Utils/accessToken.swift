import PteroNet

func accessToken() -> String? {
    guard let accessToken = Keychain.load(key: "access_token") else {
        Logger().error("Access token not found")
        return nil
    }
    
    return accessToken
}
