import SwiftUI
import PteroNet
import BisquitoNet
import SafariCover
import AuthenticationServices

@Observable
final class OAuthVM: NSObject {
    private static let lastOAuthProviderKey = "last_oauth_provider"
    
    private var session: ASWebAuthenticationSession?
    private var pendingProvider: BillingAuthProvider?
    private var onLinked: (() async -> Void)?
    private var pendingTwoFAToken: String?
    private var onAuthComplete: (() -> Void)?
    
    private var lastOAuthProviderRaw = UserDefaults.standard.string(forKey: OAuthVM.lastOAuthProviderKey) ?? "" {
        didSet {
            UserDefaults.standard.set(lastOAuthProviderRaw, forKey: OAuthVM.lastOAuthProviderKey)
        }
    }
    
    var isLinkingGitHub = false
    var isLinkingGoogle = false
    var isLinkingYandex = false
    var isLinkingApple = false
    var showTwoFASheet = false
    var twoFACode = ""
    var isVerifyingTwoFA = false
    
    var lastUsedProviderName: String? {
        guard let provider = BillingAuthProvider(rawValue: lastOAuthProviderRaw) else { return nil }
        
        switch provider {
        case .github: return "GitHub"
        case .google: return "Google"
        case .yandex: return "Yandex"
        }
    }
    
    var lastUsedProvider: BillingAuthProvider? {
        BillingAuthProvider(rawValue: lastOAuthProviderRaw)
    }
    
    var isLastUsedApple: Bool {
        lastOAuthProviderRaw == "apple"
    }
    
    func disconnectAuthService(_ authService: String, onSuccess: () async -> Void) async {
        guard let accessToken = accessToken() else { return }
        
        if await disconnectOAuthAppAPI(
            authService: authService,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) != nil {
            await onSuccess()
        }
    }
    
    func startGitHubLinking(onLinked: (() async -> Void)? = nil) {
        guard !isLinkingGitHub else { return }
        
        startLinking(provider: .github, onLinked: onLinked)
    }
    
    func startGoogleLinking(onLinked: (() async -> Void)? = nil) {
        guard !isLinkingGoogle else { return }
        
        startLinking(provider: .google, onLinked: onLinked)
    }
    
    func startYandexLinking(onLinked: (() async -> Void)? = nil) {
        guard !isLinkingYandex else { return }
        
        startLinking(provider: .yandex, onLinked: onLinked)
    }
    
    func startAppleLinking(onLinked: (() async -> Void)? = nil) {
        guard !isLinkingApple else { return }
        
        self.onLinked = onLinked
        isLinkingApple = true
        
        Task {
            await startAppleAuthorization()
        }
    }
    
    private func startLinking(provider: BillingAuthProvider, onLinked: (() async -> Void)?) {
        pendingProvider = provider
        self.onLinked = onLinked
        
        switch provider {
        case .github:
            isLinkingGitHub = true
            
        case .google:
            isLinkingGoogle = true
            
        case .yandex:
            isLinkingYandex = true
        }
        
        Task {
            await startAuthFlow(for: provider)
        }
    }
    
    func handleCallback(_ url: URL, onComplete: @escaping () -> Void) {
        isLinkingGitHub = false
        isLinkingGoogle = false
        isLinkingYandex = false
        isLinkingApple = false
        pendingTwoFAToken = nil
        onAuthComplete = nil
        showTwoFASheet = false
        twoFACode = ""
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            finish(success: false, message: "Error parsing auth URL")
            return
        }
        
        let items = (components.queryItems ?? []) + fragmentItems(from: components.fragment)
        
        if let code = queryValue(in: items, names: ["code"]), !code.isEmpty {
            guard let provider = providerFromPath(components.path) else {
                finish(success: false, message: "Missing OAuth provider")
                return
            }
            
            Task {
                await performOAuthExchange(code, provider: provider, onComplete: onComplete)
            }
            
            return
        }
        
        let isLinking = (queryValue(in: items, names: ["isLinking", "is_linking"]) ?? "").asBool
        let twoFaRequired = (queryValue(in: items, names: ["twoFa", "two_fa"]) ?? "").asBool
        
        if twoFaRequired {
            guard let token = queryValue(in: items, names: ["token"]), !token.isEmpty else {
                finish(success: false, message: "Missing 2FA token")
                return
            }
            
            pendingTwoFAToken = token
            twoFACode = ""
            onAuthComplete = onComplete
            showTwoFASheet = true
            finish(success: true, message: nil)
            return
        }
        
        if let sessionToken = queryValue(in: items, names: ["sessionToken", "session_token", "accessToken", "access_token"]),
           !sessionToken.isEmpty {
            let expiresIn = queryValue(in: items, names: ["expiresIn", "expires_in"]).flatMap(Int.init)
            storeTokens(sessionToken: sessionToken, expiresIn: expiresIn)
            onComplete()
            finish(success: true, message: nil)
            return
        }
        
        if isLinking {
            onComplete()
            finish(success: true, message: nil)
            return
        }
        
        finish(success: false, message: "Error parsing auth URL")
    }
    
    private func startAuthFlow(for provider: BillingAuthProvider) async {
        let accessToken = accessToken()
        
        let authURL = await sessionFetchAuthURL(
            for: provider,
            accessToken: accessToken,
            onBillingError: { @MainActor title, subtitle in
                self.finish(success: false, message: [title, subtitle].compactMap { $0 }.joined(separator: " • "))
            }
        )
        
        guard let authURL else { return }
        
        openSafari(authURL)
    }
    
    private func finish(success: Bool, message: String?) {
        if success, let pendingProvider {
            lastOAuthProviderRaw = pendingProvider.rawValue
        }
        
        switch pendingProvider {
        case .github: isLinkingGitHub = false
        case .google: isLinkingGoogle = false
        case .yandex: isLinkingYandex = false
        case .none: break
        }
        
        pendingProvider = nil
        session = nil
        
        if let message {
            Logger().critical("\(message)")
        }
        
        Task {
            await onLinked?()
            onLinked = nil
        }
    }
    
    func verify2FA() async {
        let code = twoFACode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard code.count >= 6, let token = pendingTwoFAToken?.nonEmpty else {
            return
        }
        
        isVerifyingTwoFA = true
        defer { isVerifyingTwoFA = false }
        
        guard let decodedResponse = await sessionVerify2FAAPI(code: code, token: token, onBillingError: { @MainActor title, subtitle in
            SystemAlert.error(title, subtitle: subtitle)
        }) else {
            return
        }
        
        guard let sessionToken = decodedResponse.sessionToken?.nonEmpty else {
            SystemAlert.error("Sign-in failed", subtitle: "Session token is missing")
            return
        }
        
        storeTokens(sessionToken: sessionToken, expiresIn: decodedResponse.expiresIn)
        
        showTwoFASheet = false
        pendingTwoFAToken = nil
        twoFACode = ""
        
        onAuthComplete?()
        onAuthComplete = nil
    }
    
    private func storeTokens(sessionToken: String, expiresIn: Int?) {
        _ = expiresIn
        saveBillingSessionToken(sessionToken)
#if os(iOS)
        Task {
            await PushTokenService.sendIfPossible(accessToken: sessionToken, pushToken: ValueStore().pushToken)
        }
#endif
    }
    
    private func startAppleAuthorization() async {
        do {
            guard let authorization = await sessionFetchAppleAuthorizationParameters(
                accessToken: accessToken(),
                onBillingError: { @MainActor title, subtitle in
                    SystemAlert.error(title, subtitle: subtitle)
                }
            ) else {
                finishAppleLinking(success: false)
                return
            }
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.state = authorization.state
            request.nonce = authorization.nonce
            
            let credential = try await PasskeyAuthorizationController().perform(request)
            
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
            
            let result = await sessionCompleteAppleAuthorization(
                code: code,
                currency: .RUB,
                state: appleCredential.state ?? authorization.state,
                user: appleCredential.sessionAppleUserProfile,
                accessToken: accessToken(),
                onBillingError: { @MainActor title, subtitle in
                    SystemAlert.error(title, subtitle: subtitle)
                }
            )
            
            guard let result else {
                finishAppleLinking(success: false)
                return
            }
            
            if result.isLinking == true {
                finishAppleLinking(success: true)
                return
            }
            
            guard let sessionToken = result.sessionToken?.nonEmpty else {
                finishAppleLinking(success: false)
                return
            }
            
            storeTokens(sessionToken: sessionToken, expiresIn: result.expiresIn)
            finishAppleLinking(success: true)
        } catch {
            Logger().error("Sign in with Apple failed: \(error.localizedDescription)")
            SystemAlert.error(error)
            finishAppleLinking(success: false)
        }
    }
    
    private func finishAppleLinking(success: Bool) {
        if success {
            lastOAuthProviderRaw = "apple"
        }
        
        isLinkingApple = false
        
        Task {
            await onLinked?()
            onLinked = nil
        }
    }
    
    private func providerFromPath(_ path: String) -> BillingAuthProvider? {
        guard let lastComponent = path.split(separator: "/").last else { return nil }
        return BillingAuthProvider(rawValue: String(lastComponent))
    }
    
    private func performOAuthExchange(_ code: String, provider: BillingAuthProvider, onComplete: @escaping () -> Void) async {
        let accessToken = accessToken()
        
        let result = await sessionExchangeOAuthCode(
            code,
            provider: provider,
            accessToken: accessToken,
            onBillingError: { @MainActor title, subtitle in
                self.finish(success: false, message: [title, subtitle].compactMap { $0 }.joined(separator: " • "))
            }
        )
        
        guard let result else { return }
        
        switch result {
        case .linked:
            onComplete()
            finish(success: true, message: nil)
            
        case .login(let response):
            if response.twoFa == true {
                guard let token = response.token?.nonEmpty else {
                    finish(success: false, message: "Missing 2FA token")
                    return
                }
                
                pendingTwoFAToken = token
                twoFACode = ""
                onAuthComplete = onComplete
                showTwoFASheet = true
                finish(success: true, message: nil)
                return
            }
            
            if response.isLinking == true {
                onComplete()
                finish(success: true, message: nil)
                return
            }
            
            guard let sessionToken = response.sessionToken?.nonEmpty else {
                finish(success: false, message: "Missing session token")
                return
            }
            
            storeTokens(sessionToken: sessionToken, expiresIn: response.expiresIn)
            
            onComplete()
            finish(success: true, message: nil)
        }
    }
    
    
    private func queryValue(in items: [URLQueryItem], names: [String]) -> String? {
        for name in names {
            if let value = items.first(where: { $0.name == name })?.value {
                return value
            }
        }
        
        return nil
    }
    
    private func fragmentItems(from fragment: String?) -> [URLQueryItem] {
        guard let fragment, !fragment.isEmpty else { return [] }
        
        return fragment
            .split(separator: "&")
            .compactMap { pair in
                let parts = pair.split(separator: "=", maxSplits: 1)
                guard let name = parts.first else { return nil }
                
                let value = parts.count > 1 ? String(parts[1]) : ""
                
                return URLQueryItem(
                    name: String(name).removingPercentEncoding ?? String(name),
                    value: value.removingPercentEncoding ?? value
                )
            }
    }
}

private extension String {
    var asBool: Bool {
        let value = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return value == "true" || value == "1" || value == "yes"
    }
}

#if !os(visionOS) && !iMessage
extension OAuthVM: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
                ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        else {
            fatalError("ASWebAuthenticationSession requires an active UIWindowScene")
        }
        
        if let window = scene.windows.first {
            return window
        }
        
        return UIWindow(windowScene: scene)
    }
}
#endif
