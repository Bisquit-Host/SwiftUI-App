import SwiftUI
import PteroNet
import BisquitoNet
import SafariCover
import AuthenticationServices

@Observable
final class OAuthVM: NSObject {
    private let basePath = "https://test-api.bisquit.host"
    
    private var session: ASWebAuthenticationSession?
    private var pendingProvider: BillingAuthProvider?
    private var onLinked: (() -> Void)?
    private var pendingTwoFAToken: String?
    private var onAuthComplete: (() -> Void)?
    
    var isLinkingGitHub = false
    var isLinkingGoogle = false
    var isLinkingYandex = false
    var showTwoFASheet = false
    var twoFACode = ""
    var isVerifyingTwoFA = false
    
    func disconnectAuthService(_ authService: String, onSuccess: () async -> Void) async {
        let path = "\(Endpoint.basePath)user/settings/social/\(authService)"
        await disconnect(path: path, onSuccess: onSuccess)
    }
    
    private func disconnect(path: String, onSuccess: () async -> Void) async {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return
        }
        
        guard let url = URL(string: path) else { return }
        
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: req)
            
            if let code = (response as? HTTPURLResponse)?.statusCode, code == 204 {
                await onSuccess()
            }
        } catch {
            print(error)
        }
    }
    
    func startGitHubLinking(onLinked: (() -> Void)? = nil) {
        guard !isLinkingGitHub else { return }
        
        startLinking(provider: .github, onLinked: onLinked)
    }
    
    func startGoogleLinking(onLinked: (() -> Void)? = nil) {
        guard !isLinkingGoogle else { return }
        
        startLinking(provider: .google, onLinked: onLinked)
    }
    
    func startYandexLinking(onLinked: (() -> Void)? = nil) {
        guard !isLinkingYandex else { return }
        
        startLinking(provider: .yandex, onLinked: onLinked)
    }
    
    private func startLinking(provider: BillingAuthProvider, onLinked: (() -> Void)?) {
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
        
        let items = components.queryItems ?? []
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
        
        guard let url = URL(string: "\(basePath)/auth/providers/\(provider.rawValue)?mobile=true") else {
            finish(success: false, message: "Invalid backend URL")
            return
        }
        
        print("Fetching auth URL from:", url)
        
        var request = URLRequest(url: url)
        
        if let accessToken {
            print("fetching authURL with access token")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("fetching authURL without access token")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let code = (response as? HTTPURLResponse)?.statusCode, code != 200 {
                finish(success: false, message: "Unexpected status: \(code)")
                return
            }
            
            let authURL = try BigAssDecoder.decode(AuthURLResponse.self, from: data).url
            
            print("Auth URL:", authURL)
            
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
        
        onLinked?()
        onLinked = nil
    }
    
    func verifyTwoFA() async {
        let code = twoFACode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard code.count >= 6, let token = pendingTwoFAToken?.nonEmpty else {
            return
        }
        
        guard let url = URL(string: "\(Endpoint.basePath)auth/two-fa") else {
            SystemAlert.error("Invalid backend URL")
            return
        }
        
        isVerifyingTwoFA = true
        defer { isVerifyingTwoFA = false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "code": code,
            "token": token
        ])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                let message = String(data: data, encoding: .utf8) ?? "Invalid response"
                SystemAlert.error(message)
                return
            }
            
            let decodedResponse = try BigAssDecoder.decode(BillingLoginResponse.self, from: data)
            storeTokens(accessToken: decodedResponse.accessToken, refreshToken: decodedResponse.refreshToken, expiresIn: decodedResponse.expiresIn)
            
            showTwoFASheet = false
            pendingTwoFAToken = nil
            twoFACode = ""
            
            onAuthComplete?()
            onAuthComplete = nil
        } catch {
            SystemAlert.error(error.localizedDescription)
        }
    }
    
    private func storeTokens(accessToken: String, refreshToken: String, expiresIn: Int) {
        Keychain.save(accessToken, forKey: "access_token")
        Keychain.save(refreshToken, forKey: "refresh_token")
        ValueStore().accessTokenExpiresIn = expiresIn
    }
    
    private func queryValue(in items: [URLQueryItem], names: [String]) -> String? {
        for name in names {
            if let value = items.first(where: { $0.name == name })?.value {
                return value
            }
        }
        return nil
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
