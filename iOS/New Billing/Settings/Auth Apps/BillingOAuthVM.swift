import AuthenticationServices
import Foundation
import UIKit

private enum Provider {
    case github, google, yandex
}

private struct AuthURLResponse: Decodable {
    let url: String
}

@Observable
final class BillingOAuthVM: NSObject {
    private let backendBase = "https://test-api.bisquit.host"
    
    private var session: ASWebAuthenticationSession?
    private var pendingProvider: Provider?
    private var onLinked: (() -> Void)?
    
    var isLinkingGitHub = false
    var isLinkingGoogle = false
    var isLinkingYandex = false
    var errorMessage: String?
    
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
        guard let url = URL(string: path) else { return }
        
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(ValueStore().testAccessToken)", forHTTPHeaderField: "Authorization")
        
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
    
    private func startLinking(provider: Provider, onLinked: (() -> Void)?) {
        pendingProvider = provider
        self.onLinked = onLinked
        errorMessage = nil
        
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
        guard let pendingProvider else { return }
        guard url.path.lowercased() == "/auth/providers/\(pendingProvider.pathComponent)" else { return }
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            finish(success: false, message: "Missing code in callback")
            return
        }
        
        Task {
            await exchangeCode(code, for: pendingProvider)
        }
    }
    
    private func fetchAuthURL(for provider: Provider) async {
        guard let url = URL(string: "\(backendBase)/auth/providers/\(provider.pathComponent)") else {
            finish(success: false, message: "Invalid backend URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = bearerToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let code = (response as? HTTPURLResponse)?.statusCode, code != 200 {
                finish(success: false, message: "Unexpected status: \(code)")
                return
            }
            
            let authURL = try JSONDecoder().decode(AuthURLResponse.self, from: data).url
            
            guard let url = URL(string: authURL) else {
                finish(success: false, message: "Invalid auth URL returned")
                return
            }
            
            startSession(url)
        } catch {
            finish(success: false, message: error.localizedDescription)
        }
    }
    
    private func startSession(_ url: URL) {
        session = ASWebAuthenticationSession(url: url, callbackURLScheme: "https") { callbackURL, error in
            if let callbackURL {
                self.handleCallback(callbackURL)
            } else {
                self.finish(success: false, message: error?.localizedDescription)
            }
        }
        
        session?.presentationContextProvider = self
        session?.start()
    }
    
    private func exchangeCode(_ code: String, for provider: Provider) async {
        guard let url = URL(string: "\(backendBase)/auth/providers/\(provider.pathComponent)") else {
            finish(success: false, message: "Invalid backend URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = bearerToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try? JSONEncoder().encode(["code": code])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                finish(success: false, message: "No HTTP response")
                return
            }
            
            switch http.statusCode {
            case 204:
                finish(success: true, message: nil)
                
            case 200:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let login = try? decoder.decode(BillingLoginResponse.self, from: data) {
                    let store = ValueStore()
                    store.testAccessToken = login.accessToken
                    store.testRefreshToken = login.refreshToken
                    store.testExpiresIn = login.expiresIn
                    finish(success: true, message: nil)
                } else {
                    finish(success: false, message: "Failed to parse tokens")
                }
                
            default:
                finish(success: false, message: "Unexpected status: \(http.statusCode)")
            }
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
        errorMessage = message
        
        onLinked?()
        onLinked = nil
    }
    
    private var bearerToken: String? {
        let token = ValueStore().testAccessToken
        return token.isEmpty ? nil : token
    }
}

private extension Provider {
    var pathComponent: String {
        switch self {
        case .github: "github"
        case .google: "google"
        case .yandex: "yandex"
        }
    }
}

extension BillingOAuthVM: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first
        else {
            return ASPresentationAnchor()
        }
        
        return window
    }
}
