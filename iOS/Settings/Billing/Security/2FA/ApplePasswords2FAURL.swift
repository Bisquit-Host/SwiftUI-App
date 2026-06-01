import Foundation

enum ApplePasswords2FAURL {
    static func make(serviceName: String, accountName: String, secret: String, issuer: String) -> URL? {
        var components = URLComponents()
        components.scheme = "apple-otpauth"
        components.host = "totp"
        components.path = "/\(serviceName):\(accountName)"
        
        components.queryItems = [
            URLQueryItem(name: "secret", value: secret),
            URLQueryItem(name: "digits", value: "6"),
            URLQueryItem(name: "period", value: "30"),
            URLQueryItem(name: "issuer", value: issuer)
        ]
        
        return components.url
    }
}
