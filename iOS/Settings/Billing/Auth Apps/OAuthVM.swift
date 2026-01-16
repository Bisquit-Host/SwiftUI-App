import SwiftUI
import PteroNet
import BisquitoNet
import SafariCover
import AuthenticationServices

@Observable
final class OAuthVM: NSObject {
    private let basePath = "https://test-api.bisquit.host"
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
    
    func disconnectAuthService(_ authService: String, onSuccess: () async -> Void) async {
        guard let accessToken = accessToken() else { return }
        
        if await disconnectOAuthAppAPI(authService: authService, accessToken: accessToken) {
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
            await fetchAuthURL(for: provider)
        }
    }
    
    func handleCallback(_ url: URL, onComplete: @escaping () -> Void) {
        isLinkingGitHub = false
        isLinkingGoogle = false
        isLinkingYandex = false
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
                await exchangeOAuthCode(code, provider: provider, onComplete: onComplete)
            }
            
            return
        }
        
        if let accessToken = queryValue(in: items, names: ["access_token"]), !accessToken.isEmpty {
            guard providerFromPath(components.path) == .yandex else {
                finish(success: false, message: "Unsupported OAuth provider")
                return
            }
            
            Task {
                await exchangeOAuthCode(accessToken, provider: .yandex, onComplete: onComplete)
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
        
        if let accessToken = queryValue(in: items, names: ["accessToken", "access_token"]),
           let refreshToken = queryValue(in: items, names: ["refreshToken", "refresh_token"]),
           let expiresInString = queryValue(in: items, names: ["expiresIn", "expires_in"]),
           let expiresIn = Int(expiresInString),
           !accessToken.isEmpty,
           !refreshToken.isEmpty {
            storeTokens(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn)
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
    
    private func fetchAuthURL(for provider: BillingAuthProvider) async {
        let accessToken = Keychain.load(key: "access_token")
        
        guard let url = URL(string: "\(basePath)/auth/providers/\(provider.rawValue)") else {
            finish(success: false, message: "Invalid backend URL")
            return
        }
        
        Logger().info("Fetching auth URL from: \(url)")
        
        var request = URLRequest(url: url)
        
        if let accessToken {
            Logger().info("fetching authURL with access token")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            Logger().info("fetching authURL without access token")
        }
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if let code = (res as? HTTPURLResponse)?.statusCode, code != 200 {
                finish(success: false, message: "Unexpected status: \(code)")
                return
            }
            
            let authURL = try BigAssDecoder.decode(AuthURLResponse.self, from: data).url
            
            Logger().info("Auth URL: \(authURL)")
            
            guard let url = URL(string: authURL) else {
                finish(success: false, message: "Invalid auth URL returned")
                return
            }
            
            openSafari(url)
        } catch {
            finish(success: false, message: error.localizedDescription)
        }
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
        
        guard let decodedResponse = await verify2FAAPI(code: code, token: token, onBillingError: { @MainActor title, subtitle in
            SystemAlert.error(title, subtitle: subtitle)
        }) else {
            return
        }
        
        storeTokens(accessToken: decodedResponse.accessToken, refreshToken: decodedResponse.refreshToken, expiresIn: decodedResponse.expiresIn)
        
        showTwoFASheet = false
        pendingTwoFAToken = nil
        twoFACode = ""
        
        onAuthComplete?()
        onAuthComplete = nil
    }
    
    private func storeTokens(accessToken: String, refreshToken: String, expiresIn: Int) {
        Keychain.save(accessToken, forKey: "access_token")
        Keychain.save(refreshToken, forKey: "refresh_token")
        ValueStore().accessTokenExpiresIn = expiresIn
    }
    
    private func providerFromPath(_ path: String) -> BillingAuthProvider? {
        guard let lastComponent = path.split(separator: "/").last else { return nil }
        return BillingAuthProvider(rawValue: String(lastComponent))
    }
    
    private func exchangeOAuthCode(
        _ code: String,
        provider: BillingAuthProvider,
        onComplete: @escaping () -> Void
    ) async {
        guard let url = URL(string: "\(basePath)/auth/providers/\(provider.rawValue)") else {
            finish(success: false, message: "Invalid backend URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = Keychain.load(key: "access_token") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(OAuthCodeRequest(code: code))
        } catch {
            finish(success: false, message: "Failed to encode OAuth request")
            return
        }
        
        await handleOAuthExchange(request: request, onComplete: onComplete)
    }
    
    private func handleOAuthExchange(request: URLRequest, onComplete: @escaping () -> Void) async {
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            let status = (res as? HTTPURLResponse)?.statusCode ?? 0
            
            if status == 204 {
                onComplete()
                finish(success: true, message: nil)
                return
            }
            
            guard status == 200 else {
                finish(success: false, message: "Unexpected status: \(status)")
                return
            }
            
            let response = try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
            
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
            
            storeTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresIn: response.expiresIn
            )
            
            onComplete()
            finish(success: true, message: nil)
        } catch {
            finish(success: false, message: error.localizedDescription)
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

private struct OAuthCodeRequest: Encodable {
    let code: String
}

private struct YandexAccessTokenRequest: Encodable {
    let accessToken: String
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
