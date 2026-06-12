import Foundation
import BisquitoNet
import AuthenticationServices
import OSLog
@preconcurrency import DeviceCheck

@Observable
final class LoginVM {
    var isPasskeyLoading = false
    var isAppleLoading = false
    var isVerifying2FA = false
    var isAttesting = false
    var attestationResult: AttestResult?
    var shouldShowCaptcha = false
    var selectedCurrency: BillingCurrency = .RUB
    
    private let passkeyAuth = PasskeyAuthorizationController()
    
    var isAppAttestSupported: Bool {
        DCAppAttestService.shared.isSupported
    }
    
    func performAppAttest(userID: String? = nil) async -> Bool {
        isAttesting = true
        
        defer {
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                isAttesting = false
            }
        }
        
        do {
            let result = try await AttestService.shared.attestDevice(userID: userID)
            attestationResult = result
            
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }
    
    func login(_ login: String, _ password: String, captchaToken: String? = nil, attestResponse: AttestResult? = nil) async -> BillingSessionAuthResponse? {
        let attestationPayload = attestResponse.map {
            [
                "challenge": $0.challenge,
                "attestation": $0.attestation,
                "keyID": $0.keyID
            ]
        }
        
        return await sessionLoginAPI(
            login: login,
            password: password,
            captchaToken: captchaToken,
            attestResponse: attestationPayload,
            onBillingError: { @MainActor title, subtitle in
                self.handleBillingError(title, subtitle)
            }
        )
    }
    
    func signup(name: String, email: String, password: String, captchaToken: String? = nil, attestResponse: AttestResult? = nil) async -> BillingSessionAuthResponse? {
        let attestationPayload = attestResponse.map {
            [
                "challenge": $0.challenge,
                "attestation": $0.attestation,
                "keyID": $0.keyID
            ]
        }
        
        return await sessionSignupAPI(
            name: name,
            email: email,
            password: password,
            currency: selectedCurrency,
            captchaToken: captchaToken,
            attestResponse: attestationPayload,
            onBillingError: { @MainActor title, subtitle in
                self.handleBillingError(title, subtitle)
            }
        )
    }
    
    func verify2FA(code: String, token: String) async -> BillingSessionAuthResponse? {
        isVerifying2FA = true
        defer { isVerifying2FA = false }
        
        return await sessionVerify2FAAPI(code: code, token: token, onBillingError: { @MainActor title, subtitle in
            SystemAlert.error(title, subtitle: subtitle)
        })
    }

    private func handleBillingError(_ title: String, _ subtitle: String?) {
        SystemAlert.error(title, subtitle: subtitle)
        
        guard shouldFallbackToCaptcha(subtitle) else { return }
        attestationResult = nil
        shouldShowCaptcha = true
    }
    
    private func shouldFallbackToCaptcha(_ subtitle: String?) -> Bool {
        guard attestationResult != nil else { return false }
        guard let code = statusCode(from: subtitle) else { return false }
        
        return code == 400
    }
    
    private func statusCode(from subtitle: String?) -> Int? {
        guard let subtitle else { return nil }
        let parts = subtitle.split(separator: "•", maxSplits: 1, omittingEmptySubsequences: true)
        guard let first = parts.first else { return nil }
        
        return Int(first.trimmingCharacters(in: .whitespaces))
    }
    
    func loginWithPasskey(_ login: String?) async -> BillingSessionAuthResponse? {
        isPasskeyLoading = true
        defer { isPasskeyLoading = false }
        
        do {
            let session = try await startPasskeyLoginAPI(login: login)
            let req = try PasskeyRequestFactory.assertionRequest(from: session.options)
            let credential = try await passkeyAuth.perform(req)
            
            guard let assertion = credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion else {
                throw PasskeyError.invalidCredential
            }
            
            let payload = try PasskeyCredentialFormatter.assertionPayload(assertion)
            
            return try await sessionVerifyPasskeyLoginAPI(sessionId: session.sessionId, credential: payload)
        } catch {
            Logger().error("Passkey login failed: \(error.localizedDescription)")
            SystemAlert.error(error)
            return nil
        }
    }
    
    func loginWithApple() async -> BillingSessionAuthResponse? {
        isAppleLoading = true
        defer { isAppleLoading = false }
        
        do {
            guard let authorization = await sessionFetchAppleAuthorizationParameters(onBillingError: { @MainActor title, subtitle in
                SystemAlert.error(title, subtitle: subtitle)
            }) else {
                return nil
            }
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.state = authorization.state
            request.nonce = authorization.nonce
            
            let credential = try await passkeyAuth.perform(request)
            
            guard let appleCredential = credential as? ASAuthorizationAppleIDCredential else {
                throw AppleSignInError.invalidCredential
            }
            
            guard
                let codeData = appleCredential.authorizationCode,
                let code = String(data: codeData, encoding: .utf8),
                !code.isEmpty
            else {
                throw AppleSignInError.missingAuthorizationCode
            }
            
            return await sessionCompleteAppleAuthorization(
                code: code,
                currency: selectedCurrency,
                state: appleCredential.state ?? authorization.state,
                user: appleCredential.sessionAppleUserProfile,
                onBillingError: { @MainActor title, subtitle in
                    SystemAlert.error(title, subtitle: subtitle)
                }
            )
        } catch {
            Logger().error("Sign in with Apple failed: \(error.localizedDescription)")
            SystemAlert.error(error)
            return nil
        }
    }
}

struct BillingSessionAuthResponse: Decodable {
    let sessionToken: String?
    let expiresIn: Int?
    let isLinking: Bool?
    let twoFa: Bool?
    let token: String?
    
    private enum CodingKeys: String, CodingKey {
        case sessionToken
        case accessToken
        case expiresIn
        case isLinking
        case twoFa
        case token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sessionToken = try container.decodeIfPresent(String.self, forKey: .sessionToken)
            ?? container.decodeIfPresent(String.self, forKey: .accessToken)
        expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
        isLinking = try container.decodeIfPresent(Bool.self, forKey: .isLinking)
        twoFa = try container.decodeIfPresent(Bool.self, forKey: .twoFa)
        token = try container.decodeIfPresent(String.self, forKey: .token)
    }
}

enum SessionOAuthExchangeResult {
    case linked
    case login(BillingSessionAuthResponse)
}

private enum BillingAuthEndpoint {
    static let basePath = "https://api.bisquit.host/"
    
    static let signin = basePath + "auth/signin"
    static let signup = basePath + "auth/signup"
    static let verifyTwoFA = basePath + "auth/two-fa"
    static let verifyPasskey = basePath + "auth/passkeys/verify"
    static let logout = basePath + "user/logout"
    
    static func authProvider(_ provider: BillingAuthProvider) -> String {
        basePath + "auth/providers/" + provider.rawValue
    }
    
    static func authProvider(_ provider: String) -> String {
        basePath + "auth/providers/" + provider
    }
    
    static let nativeAppleProvider = basePath + "auth/providers/apple/native"
}

private struct SessionAuthURLResponse: Decodable {
    let url: String
}

struct SessionAppleAuthorizationParameters: Decodable {
    let clientId: String
    let state: String
    let nonce: String
}

struct SessionAppleAuthorizationRequest: Encodable {
    let code: String
    let currency: String
    let state: String
    let user: SessionAppleUserProfile?
}

struct SessionAppleUserProfile: Encodable {
    let name: SessionAppleUserName?
    let email: String?
}

struct SessionAppleUserName: Encodable {
    let firstName: String?
    let lastName: String?
}

extension ASAuthorizationAppleIDCredential {
    var sessionAppleUserProfile: SessionAppleUserProfile? {
        let firstName = fullName?.givenName?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        let lastName = fullName?.familyName?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        let email = email?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty
        let name = firstName == nil && lastName == nil
            ? nil
            : SessionAppleUserName(firstName: firstName, lastName: lastName)
        
        guard name != nil || email != nil else { return nil }
        return SessionAppleUserProfile(name: name, email: email)
    }
}

func sessionLoginAPI(
    login: String,
    password: String,
    captchaToken: String? = nil,
    attestResponse: [String: String]? = nil,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> BillingSessionAuthResponse? {
    guard let url = URL(string: BillingAuthEndpoint.signin) else {
        await MainActor.run {
            onBillingError("Invalid URL", nil)
        }
        return nil
    }
    
    var body: [String: Any] = [
        "login": login.lowercased(),
        "password": password
    ]
    
    if let attestResponse {
        body["attestResponse"] = attestResponse
    } else if let captchaToken {
        body["captchaResponse"] = captchaToken
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    return await decodeSessionAuthResponse(request, in: #function, onBillingError: onBillingError)
}

func sessionSignupAPI(
    name: String,
    email: String,
    password: String,
    currency: BillingCurrency,
    captchaToken: String? = nil,
    attestResponse: [String: String]? = nil,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> BillingSessionAuthResponse? {
    guard let url = URL(string: BillingAuthEndpoint.signup) else {
        await MainActor.run {
            onBillingError("Invalid URL", nil)
        }
        return nil
    }
    
    var body: [String: Any] = [
        "email": email.lowercased(),
        "password": password,
        "name": name,
        "currency": currency.rawValue
    ]
    
    if let attestResponse {
        body["attestResponse"] = attestResponse
    } else if let captchaToken {
        body["captchaResponse"] = captchaToken
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    return await decodeSessionAuthResponse(request, in: #function, onBillingError: onBillingError)
}

func sessionVerify2FAAPI(
    code: String,
    token: String,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> BillingSessionAuthResponse? {
    guard let url = URL(string: BillingAuthEndpoint.verifyTwoFA) else {
        await MainActor.run {
            onBillingError("Invalid URL", nil)
        }
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: [
        "code": code,
        "token": token
    ])
    
    return await decodeSessionAuthResponse(request, in: #function, onBillingError: onBillingError)
}

func sessionVerifyPasskeyLoginAPI(sessionId: String, credential: PasskeyAssertionPayload) async throws -> BillingSessionAuthResponse {
    guard let url = URL(string: BillingAuthEndpoint.verifyPasskey) else {
        throw URLError(.badURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    struct Body: Encodable {
        let sessionId: String
        let credential: PasskeyAssertionPayload
    }
    
    request.httpBody = try JSONEncoder().encode(Body(sessionId: sessionId, credential: credential))
    
    let (data, res) = try await URLSession.shared.data(for: request)
    prettyJSON(data)
    
    guard let http = res as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    Logger().info("\(http.statusCode) • \(#function)")

    guard http.statusCode == 200 else {
        let error = passkeyAPIError(data: data, response: http, endpoint: "Verify passkey login")
        Logger().error("\(error.localizedDescription)")
        throw error
    }
    
    return try JSONDecoder().decode(BillingSessionAuthResponse.self, from: data)
}

private func passkeyAPIError(data: Data, response: HTTPURLResponse, endpoint: String) -> NSError {
    let body = String(data: data, encoding: .utf8)
    let billingError = try? JSONDecoder().decode(BillingError.self, from: data)
    var message = "\(endpoint) failed with HTTP \(response.statusCode)"

    if let billingError {
        message += " • \(billingError.title): \(billingError.detail)"
    } else if let body, !body.isEmpty {
        message += " • \(body)"
    }

    return NSError(
        domain: "BisquitHost.PasskeyLogin",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey: message]
    )
}

func sessionFetchAuthURL(
    for provider: BillingAuthProvider,
    accessToken: String? = nil,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> URL? {
    guard let url = URL(string: BillingAuthEndpoint.authProvider(provider)) else {
        await MainActor.run {
            onBillingError("Invalid URL", nil)
        }
        return nil
    }
    
    var request = URLRequest(url: url)
    if let accessToken {
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    do {
        let (data, res) = try await URLSession.shared.data(for: request)
        prettyJSON(data)
        
        if decodeBillingError(data, with: res, in: #function, onDecode: { @MainActor title, subtitle in
            onBillingError(title, subtitle)
        }) {
            return nil
        }
        
        guard let http = res as? HTTPURLResponse else {
            await MainActor.run {
                onBillingError("No response", nil)
            }
            return nil
        }
        
        guard http.statusCode == 200 else {
            await MainActor.run {
                onBillingError("Unexpected status", "\(http.statusCode)")
            }
            
            return nil
        }
        
        let authURL = try JSONDecoder().decode(SessionAuthURLResponse.self, from: data).url
        
        guard let result = URL(string: authURL) else {
            await MainActor.run {
                onBillingError("Invalid auth URL returned", nil)
            }
            
            return nil
        }
        
        return result
    } catch {
        Logger().error("\(error)")
        
        await MainActor.run {
            onBillingError("Request failed", error.localizedDescription)
        }
        
        return nil
    }
}

func sessionFetchAppleAuthorizationParameters(
    accessToken: String? = nil,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> SessionAppleAuthorizationParameters? {
    guard let url = URL(string: BillingAuthEndpoint.nativeAppleProvider) else {
        await MainActor.run {
            onBillingError("Invalid URL", nil)
        }
        return nil
    }
    
    var request = URLRequest(url: url)
    if let accessToken {
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    do {
        let (data, res) = try await URLSession.shared.data(for: request)
        prettyJSON(data)
        
        if decodeBillingError(data, with: res, in: #function, onDecode: { @MainActor title, subtitle in
            onBillingError(title, subtitle)
        }) {
            return nil
        }
        
        guard let http = res as? HTTPURLResponse else {
            await MainActor.run {
                onBillingError("No response", nil)
            }
            return nil
        }
        
        guard http.statusCode == 200 else {
            await MainActor.run {
                onBillingError("Unexpected status", "\(http.statusCode)")
            }
            return nil
        }
        
        let authorization = try JSONDecoder().decode(SessionAppleAuthorizationParameters.self, from: data)
        
        guard
            !authorization.clientId.isEmpty,
            !authorization.state.isEmpty,
            !authorization.nonce.isEmpty
        else {
            await MainActor.run {
                onBillingError("Incomplete Apple authorization parameters", nil)
            }
            return nil
        }
        
        return authorization
    } catch {
        Logger().error("\(error)")
        
        await MainActor.run {
            onBillingError("Request failed", error.localizedDescription)
        }
        
        return nil
    }
}

func sessionExchangeOAuthCode(
    _ code: String,
    provider: BillingAuthProvider,
    accessToken: String? = nil,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> SessionOAuthExchangeResult? {
    
    guard let url = URL(string: BillingAuthEndpoint.authProvider(provider)) else {
        await MainActor.run {
            onBillingError("Invalid URL", nil)
        }
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let accessToken {
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    do {
        request.httpBody = try JSONEncoder().encode(["code": code])
    } catch {
        await MainActor.run {
            onBillingError("Failed to encode OAuth request", nil)
        }
        return nil
    }
    
    do {
        let (data, res) = try await URLSession.shared.data(for: request)
        prettyJSON(data)
        
        if decodeBillingError(data, with: res, in: #function, onDecode: { @MainActor title, subtitle in
            onBillingError(title, subtitle)
        }) {
            return nil
        }
        
        guard let http = res as? HTTPURLResponse else {
            await MainActor.run {
                onBillingError("No response", nil)
            }
            return nil
        }
        
        if http.statusCode == 204 {
            return .linked
        }
        
        guard http.statusCode == 200 else {
            await MainActor.run {
                onBillingError("Unexpected status", "\(http.statusCode)")
            }
            return nil
        }
        
        return .login(try JSONDecoder().decode(BillingSessionAuthResponse.self, from: data))
    } catch {
        Logger().error("\(error)")
        
        await MainActor.run {
            onBillingError("Request failed", error.localizedDescription)
        }
        
        return nil
    }
}

func sessionCompleteAppleAuthorization(
    code: String,
    currency: BillingCurrency,
    state: String,
    user: SessionAppleUserProfile?,
    accessToken: String? = nil,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> BillingSessionAuthResponse? {
    
    guard let url = URL(string: BillingAuthEndpoint.nativeAppleProvider) else {
        await MainActor.run {
            onBillingError("Invalid URL", nil)
        }
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let accessToken {
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    do {
        request.httpBody = try JSONEncoder().encode(
            SessionAppleAuthorizationRequest(
                code: code,
                currency: currency.rawValue,
                state: state,
                user: user
            )
        )
    } catch {
        await MainActor.run {
            onBillingError("Failed to encode Apple sign-in request", nil)
        }
        return nil
    }
    
    return await decodeSessionAuthResponse(request, in: #function, onBillingError: onBillingError)
}

func billingLogoutAPI(
    accessToken: String,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> Bool {
    guard let url = URL(string: BillingAuthEndpoint.logout) else {
        await MainActor.run {
            onBillingError("Invalid URL", nil)
        }
        
        return false
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    do {
        let (data, res) = try await URLSession.shared.data(for: request)
        prettyJSON(data)
        
        if decodeBillingError(data, with: res, in: #function, onDecode: { @MainActor title, subtitle in
            onBillingError(title, subtitle)
        }) {
            return false
        }
        
        guard let statusCode = (res as? HTTPURLResponse)?.statusCode else {
            await MainActor.run {
                onBillingError("No response", nil)
            }
            
            return false
        }
        
        return (200...299).contains(statusCode)
    } catch {
        await MainActor.run {
            onBillingError("Request failed", error.localizedDescription)
        }
        return false
    }
}

private func prettyJSON(_ data: Data) {
#if DEBUG
    guard !data.isEmpty else { return }
    guard let object = try? JSONSerialization.jsonObject(with: data) else { return }
    guard let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) else { return }
    guard let text = String(data: prettyData, encoding: .utf8) else { return }
    
    Logger().debug("\n\(text)")
#endif
}

private func decodeSessionAuthResponse(
    _ request: URLRequest,
    in function: String,
    onBillingError: @MainActor @escaping (String, String?) -> Void
) async -> BillingSessionAuthResponse? {
    do {
        let (data, res) = try await URLSession.shared.data(for: request)
        prettyJSON(data)
        
        if decodeBillingError(data, with: res, in: function, onDecode: { @MainActor title, subtitle in
            onBillingError(title, subtitle)
        }) {
            return nil
        }
        
        return try JSONDecoder().decode(BillingSessionAuthResponse.self, from: data)
    } catch {
        await MainActor.run {
            onBillingError("Error", error.localizedDescription)
        }
        return nil
    }
}
