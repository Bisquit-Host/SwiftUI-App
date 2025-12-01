import Foundation

struct PasskeyOptionsResponse<Options: Decodable>: Decodable {
    let sessionId: String
    let options: Options
}

struct PasskeyCredentialDescriptor: Decodable {
    let id: String
    let type: String?
    let transports: [String]?
}

struct PasskeyAssertionOptions: Decodable {
    let challenge: String
    let rpId: String?
    let timeout: Int?
    let allowCredentials: [PasskeyCredentialDescriptor]?
    let userVerification: String?
}

struct PasskeyRp: Decodable {
    let id: String
    let name: String
}

struct PasskeyUser: Decodable {
    let id: String
    let name: String
    let displayName: String
}

struct PasskeyAuthenticatorSelection: Decodable {
    let userVerification: String?
    let residentKey: String?
}

struct PasskeyRegistrationOptions: Decodable {
    let challenge: String
    let rp: PasskeyRp
    let user: PasskeyUser
    let timeout: Int?
    let excludeCredentials: [PasskeyCredentialDescriptor]?
    let authenticatorSelection: PasskeyAuthenticatorSelection?
    let attestation: String?
}

struct PasskeyListItem: Decodable, Identifiable, Equatable {
    let id: Int
    let nickname: String?
    let createdAt: String
    let lastUsedAt: String?
    let transports: [String]
    let backedUp: Bool
    let userVerified: Bool
}
