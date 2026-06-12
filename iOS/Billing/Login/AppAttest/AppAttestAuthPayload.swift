import Foundation
import BisquitoNet

struct AppAttestAuthPayload {
    let action: String
    let data: Data
    
    static func signin(login: String, password: String) -> AppAttestAuthPayload {
        AppAttestAuthPayload(
            action: "signin",
            fields: [
                ("login", login.lowercased()),
                ("password", password)
            ]
        )
    }
    
    static func signup(name: String, email: String, password: String, currency: BillingCurrency) -> AppAttestAuthPayload {
        AppAttestAuthPayload(
            action: "signup",
            fields: [
                ("email", email.lowercased()),
                ("password", password),
                ("name", name),
                ("currency", currency.rawValue)
            ]
        )
    }
    
    private init(action: String, fields: [(String, String)]) {
        self.action = action
        data = Self.canonicalData(action: action, fields: fields)
    }
    
    private static func canonicalData(action: String, fields: [(String, String)]) -> Data {
        let lines = [
            "app-attest-auth-v1",
            "action=\(action)"
        ] + fields.map { "\($0.0)=\(Data($0.1.utf8).base64EncodedString())" }
        
        return Data(lines.joined(separator: "\n").utf8)
    }
}
