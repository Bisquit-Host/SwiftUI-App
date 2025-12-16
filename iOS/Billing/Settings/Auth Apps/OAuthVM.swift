import SwiftUI
import PteroNet
import SafariCover
import AuthenticationServices

@Observable
final class OAuthVM: NSObject {
    private let basePath = "https://test-api.bisquit.host"
    
    private var session: ASWebAuthenticationSession?
    private var pendingProvider: BillingAuthProvider?
    private var onLinked: (() -> Void)?
    
    var isLinkingGitHub = false
    var isLinkingGoogle = false
    var isLinkingYandex = false
    
    func disconnectGithub(onSuccess: () async -> Void) async {
        let path = "https://test-api.bisquit.host/user/settings/social/github"
        await disconnect(path: path, onSuccess: onSuccess)
    }
    
    func disconnectGoogle(onSuccess: () async -> Void) async {
        let path = "https://test-api.bisquit.host/user/settings/social/google"
        await disconnect(path: path, onSuccess: onSuccess)
    }
    
    func disconnectYandex(onSuccess: () async -> Void) async {
        let path = "https://test-api.bisquit.host/user/settings/social/yandex"
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
    
    func handleCallback(_ url: URL) {
        isLinkingGitHub = false
        isLinkingGoogle = false
        isLinkingYandex = false
        
        guard let pendingProvider else { return }
        guard url.path.lowercased() == "/auth/providers/\(pendingProvider.rawValue)" else { return }
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let accessToken = components.queryItems?.first(where: { $0.name == "accessToken" })?.value,
            let refreshToken = components.queryItems?.first(where: { $0.name == "refreshToken" })?.value,
            let expiresInString = components.queryItems?.first(where: { $0.name == "expiresIn" })?.value,
            let expiresIn = Int(expiresInString)
        else {
            finish(success: false, message: "Duck me")
            return
        }
        
        Keychain.save(accessToken, forKey: "access_token")
        Keychain.save(refreshToken, forKey: "refresh_token")
        ValueStore().testExpiresIn = expiresIn
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
            
            let authURL = try JSONDecoder().decode(AuthURLResponse.self, from: data).url
            
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
        case .github:
            isLinkingGitHub = false
            
        case .google:
            isLinkingGoogle = false
            
        case .yandex:
            isLinkingYandex = false
            
        case .none:
            break
        }
        
        pendingProvider = nil
        session = nil
        
        if let message {
            print(message)
        }
        
        onLinked?()
        onLinked = nil
    }
}

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
