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
    var shouldShowCaptcha = false
    var selectedCurrency: BillingCurrency = Locale.current.identifier.localizedCaseInsensitiveContains("ru") ? .RUB : .EUR
    
    var isSignUp = false {
        didSet {
            if !isSignUp {
                hasAcceptedDocuments = false
            }
        }
    }
    var name = ""
    var loginInput = ""
    var password = ""
    var hasAcceptedDocuments = false
    var captchaToken = ""
    var pending2FAToken: String?
    var twoFACode = ""
    var sheet2FA = false
    private(set) var isAuthenticating = false
    private(set) var sessionToken: String?
    private(set) var completedOAuthProvider: BillingSessionAuthServiceName?
    private var pendingOAuthProvider: BillingSessionAuthServiceName?

    private let passkeyAuth = PasskeyAuthorizationController()

    init() {
        let systemLanguage = Locale.current.identifier
        Logger().info("System language: \(systemLanguage, privacy: .public)")
    }
    
    var isAppAttestSupported: Bool {
        DCAppAttestService.shared.isSupported
    }
    
    private var trimmedLogin: String {
        loginInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var emailValidationError: String? {
        guard isSignUp, !trimmedLogin.isEmpty else { return nil }
        return isValidEmail(trimmedLogin) ? nil : "Enter a valid email address"
    }

    var continueButtonDisabled: Bool {
        let loginEmpty = trimmedLogin.isEmpty
        let passwordEmpty = password.trimmingCharacters(in: .whitespaces).isEmpty
        let nameEmpty = name.trimmingCharacters(in: .whitespaces).isEmpty
        let documentsNotAccepted = isSignUp && !hasAcceptedDocuments
        let invalidEmail = isSignUp && !isValidEmail(trimmedLogin)

        return loginEmpty || passwordEmpty || (isSignUp && nameEmpty)
            || documentsNotAccepted || invalidEmail || isAttesting || isAuthenticating
    }

    private func isValidEmail(_ value: String) -> Bool {
        value.wholeMatch(of: /^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/) != nil
    }

    func authenticate() async {
        guard !continueButtonDisabled else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        pendingOAuthProvider = nil

        let response: BillingSessionAuthResponse?
        if isSignUp {
            response = await signup(
                name: name.trimmingCharacters(in: .whitespaces),
                email: trimmedLogin,
                password: password,
                captchaToken: captchaToken.isEmpty ? nil : captchaToken
            )
        } else {
            response = await login(
                trimmedLogin,
                password,
                captchaToken: captchaToken.isEmpty ? nil : captchaToken
            )
        }

        captchaToken = ""
        guard let response else { return }
        handleAuthResponse(response)
    }

    func handlePasskeyResponse(_ response: BillingSessionAuthResponse) {
        pendingOAuthProvider = nil
        handleAuthResponse(response)
    }

    func handleOAuthResponse(_ response: BillingSessionAuthResponse) {
        pendingOAuthProvider = .apple
        handleAuthResponse(response)
    }

    func handleAuthResponse(_ response: BillingSessionAuthResponse) {
        if response.twoFa == true {
            pending2FAToken = response.token
            twoFACode = ""
            sheet2FA = true
            return
        }

        guard let token = response.sessionToken?.nonEmpty else {
            SystemAlert.error("Sign-in failed", subtitle: "Session token is missing")
            return
        }

        sheet2FA = false
        pending2FAToken = nil
        completedOAuthProvider = pendingOAuthProvider
        pendingOAuthProvider = nil
        if isSignUp {
            name = ""
        }
        sessionToken = token
    }

    func activateSession(pushToken: String?) {
        guard let sessionToken else { return }
        saveBillingSessionToken(sessionToken)
#if os(iOS)
        Task {
            await PushTokenService.sendIfPossible(accessToken: sessionToken, pushToken: pushToken)
        }
#endif
    }

    func login(_ login: String, _ password: String, captchaToken: String? = nil) async -> BillingSessionAuthResponse? {
        let login = login.lowercased()
        
        if let captchaToken {
            return await sessionLoginAPI(
                login: login,
                password: password,
                captchaToken: captchaToken,
                onBillingError: reportBillingError
            )
        }
        
        guard isAppAttestSupported else {
            shouldShowCaptcha = true
            return nil
        }
        
        let payload = AppAttestAuthPayload.signin(login: login, password: password)
        
        return await loginWithAppAttest(
            login: login,
            password: password,
            userID: login,
            payload: payload
        )
    }
    
    func signup(name: String, email: String, password: String, captchaToken: String? = nil) async -> BillingSessionAuthResponse? {
        let name = name.trimmingCharacters(in: .whitespaces)
        let email = email.lowercased()
        
        if let captchaToken {
            return await sessionSignupAPI(
                name: name,
                email: email,
                password: password,
                currency: selectedCurrency,
                captchaToken: captchaToken,
                onBillingError: reportBillingError
            )
        }
        
        guard isAppAttestSupported else {
            shouldShowCaptcha = true
            return nil
        }
        
        let payload = AppAttestAuthPayload.signup(
            name: name,
            email: email,
            password: password,
            currency: selectedCurrency
        )
        
        return await signupWithAppAttest(
            name: name,
            email: email,
            password: password,
            userID: email,
            payload: payload
        )
    }
    
    func verify2FA(code: String, token: String) async -> BillingSessionAuthResponse? {
        isVerifying2FA = true
        defer { isVerifying2FA = false }
        
        return await sessionVerify2FAAPI(code: code, token: token, onBillingError: { @MainActor title, subtitle in
            SystemAlert.error(title, subtitle: subtitle)
        })
    }

    private func loginWithAppAttest(
        login: String,
        password: String,
        userID: String,
        payload: AppAttestAuthPayload
    ) async -> BillingSessionAuthResponse? {
        await authenticateWithAppAttest(userID: userID, payload: payload) { assertionPayload, attestationPayload in
            await sessionLoginAPIResult(
                login: login,
                password: password,
                assertResponse: assertionPayload,
                attestResponse: attestationPayload
            )
        }
    }
    
    private func signupWithAppAttest(
        name: String,
        email: String,
        password: String,
        userID: String,
        payload: AppAttestAuthPayload
    ) async -> BillingSessionAuthResponse? {
        await authenticateWithAppAttest(userID: userID, payload: payload) { assertionPayload, attestationPayload in
            await sessionSignupAPIResult(
                name: name,
                email: email,
                password: password,
                currency: selectedCurrency,
                assertResponse: assertionPayload,
                attestResponse: attestationPayload
            )
        }
    }
    
    private func authenticateWithAppAttest(
        userID: String,
        payload: AppAttestAuthPayload,
        request: ([String: String]?, [String: String]?) async -> SessionAuthRequestResult
    ) async -> BillingSessionAuthResponse? {
        isAttesting = true
        defer { isAttesting = false }
        
        do {
            let assertion = try await AttestService.shared.assertion(
                userID: userID,
                action: payload.action,
                payload: payload.data
            )
            
            switch await request(assertion.requestPayload, nil) {
            case .success(let response):
                return response
                
            case .failure(let failure) where failure.shouldFallbackToCaptcha:
                break
                
            case .failure(let failure):
                reportBillingError(failure.title, failure.subtitle)
                return nil
            }
        } catch {
            Logger().info("App Attest assertion unavailable: \(error.localizedDescription)")
        }
        
        do {
            let attestation = try await AttestService.shared.attestDevice(userID: userID)
            
            switch await request(nil, attestation.requestPayload) {
            case .success(let response):
                return response
                
            case .failure(let failure) where failure.shouldFallbackToCaptcha:
                shouldShowCaptcha = true
                return nil
                
            case .failure(let failure):
                reportBillingError(failure.title, failure.subtitle)
                return nil
            }
        } catch {
            Logger().error("App Attest fallback failed: \(error.localizedDescription)")
            shouldShowCaptcha = true
            return nil
        }
    }
    
    private func reportBillingError(_ title: String, _ subtitle: String?) {
        SystemAlert.error(title, subtitle: subtitle)
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

private extension AttestResult {
    var requestPayload: [String: String] {
        [
            "challenge": challenge,
            "attestation": attestation,
            "keyID": keyID
        ]
    }
}

private extension AttestAssertionResult {
    var requestPayload: [String: String] {
        [
            "challenge": challenge,
            "assertion": assertion,
            "keyID": keyID,
            "clientData": clientData
        ]
    }
}
