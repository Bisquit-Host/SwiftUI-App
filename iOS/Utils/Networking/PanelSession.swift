import Calagopus
import BisquitoNet
import Foundation

#if os(iOS) && BISQUIT_HOST_APP
nonisolated struct PanelSessionCredential: Sendable {
    let sessionToken: String
    let cookieName: String
    let panelURL: String?
    let expiresAt: Date?
    
    var cookieHeader: String {
        "\(cookieName)=\(sessionToken)"
    }
    
    var baseURL: URL? {
        guard let panelURL, !panelURL.isEmpty else { return nil }
        return URL(string: panelURL)
    }
    
    var isUsable: Bool {
        guard !sessionToken.isEmpty, !cookieName.isEmpty else { return false }
        guard let expiresAt else { return true }
        return expiresAt > Date().addingTimeInterval(60)
    }
}

nonisolated enum PanelSessionStore {
    private static let sessionTokenKey = "panel_session_token"
    private static let cookieNameKey = "panel_session_cookie_name"
    private static let panelURLKey = "panel_session_panel_url"
    private static let expiresAtKey = "panel_session_expires_at"
    private static let hasSessionKey = "panel_session_has_session"
    private static let defaultCookieName = "calagopus_session"
    
    static func load() -> PanelSessionCredential? {
        guard UserDefaults.standard.bool(forKey: hasSessionKey) else {
            return nil
        }
        
        guard let sessionToken = Keychain.load(key: sessionTokenKey), !sessionToken.isEmpty else {
            UserDefaults.standard.set(false, forKey: hasSessionKey)
            return nil
        }
        
        let cookieName = nonEmptyValue(forKey: cookieNameKey) ?? defaultCookieName
        let panelURL = nonEmptyValue(forKey: panelURLKey)
        let expiresAt = Keychain.load(key: expiresAtKey)
            .flatMap(TimeInterval.init)
            .map(Date.init(timeIntervalSince1970:))
        
        return PanelSessionCredential(
            sessionToken: sessionToken,
            cookieName: cookieName,
            panelURL: panelURL,
            expiresAt: expiresAt
        )
    }
    
    @discardableResult
    static func save(_ response: PanelSessionExchangeResponse) -> PanelSessionCredential {
        let expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresSeconds))
        
        Keychain.save(response.sessionToken, forKey: sessionTokenKey)
        Keychain.save(response.cookieName, forKey: cookieNameKey)
        Keychain.save(response.panelUrl, forKey: panelURLKey)
        Keychain.save(expiresAt.timeIntervalSince1970.description, forKey: expiresAtKey)
        UserDefaults.standard.set(true, forKey: hasSessionKey)
        
        return PanelSessionCredential(
            sessionToken: response.sessionToken,
            cookieName: response.cookieName,
            panelURL: response.panelUrl,
            expiresAt: expiresAt
        )
    }
    
    @discardableResult
    static func delete() -> Bool {
        let deletedSessionToken = Keychain.delete(key: sessionTokenKey)
        let deletedCookieName = Keychain.delete(key: cookieNameKey)
        let deletedPanelURL = Keychain.delete(key: panelURLKey)
        let deletedExpiresAt = Keychain.delete(key: expiresAtKey)
        
        UserDefaults.standard.set(false, forKey: hasSessionKey)
        
        return deletedSessionToken || deletedCookieName || deletedPanelURL || deletedExpiresAt
    }
    
    private static func nonEmptyValue(forKey key: String) -> String? {
        guard let value = Keychain.load(key: key), !value.isEmpty else {
            return nil
        }
        
        return value
    }
    
    static func exchange() async throws -> PanelSessionCredential {
        guard let accessToken = accessToken() else {
            throw PanelSessionError.missingBillingSession
        }

        let exchangeResponse = try await exchangePanelSessionAPI(accessToken: accessToken)
        return save(exchangeResponse)
    }
}

actor PanelSessionCoordinator {
    static let shared = PanelSessionCoordinator()
    
    private var cachedCredential: PanelSessionCredential?
    private var refreshTask: Task<PanelSessionCredential, Error>?
    private var cachedFailure: PanelSessionError?
    private var suspendedUntil: Date?
    
    func credential(forceRefresh: Bool = false) async throws -> PanelSessionCredential {
        if let suspendedUntil, suspendedUntil > Date() {
            throw PanelSessionError.rateLimited(retryAfter: suspendedUntil)
        }
        
        if !forceRefresh, let cachedFailure {
            throw cachedFailure
        }
        
        if !forceRefresh, let cachedCredential, cachedCredential.isUsable {
            return cachedCredential
        }
        
        if !forceRefresh, let credential = PanelSessionStore.load(), credential.isUsable {
            cachedCredential = credential
            return credential
        }
        
        if let refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task {
            try await PanelSessionStore.exchange()
        }
        
        refreshTask = task
        
        do {
            let credential = try await task.value
            cachedCredential = credential
            cachedFailure = nil
            suspendedUntil = nil
            refreshTask = nil
            return credential
        } catch let error as PanelSessionError {
            if case .rateLimited(let retryAfter) = error {
                suspendedUntil = retryAfter
            }
            
            if error.isCachedFailure {
                cachedFailure = error
            }
            
            refreshTask = nil
            throw error
        } catch {
            refreshTask = nil
            throw error
        }
    }
    
    func clear() {
        refreshTask?.cancel()
        refreshTask = nil
        cachedCredential = nil
        cachedFailure = nil
        suspendedUntil = nil
    }
}

nonisolated final class PanelSessionURLProtocol: URLProtocol, @unchecked Sendable {
    static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [PanelSessionURLProtocol.self]
        configuration.httpCookieAcceptPolicy = .always
        return URLSession(configuration: configuration)
    }()
    
    private var loadingTask: Task<Void, Never>?
    
    nonisolated override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    nonisolated override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    nonisolated override func startLoading() {
        let request = request
        let loader = PanelSessionURLProtocolLoader(urlProtocol: self, request: request)
        
        loadingTask = Task {
            await loader.load()
        }
    }
    
    nonisolated override func stopLoading() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    fileprivate func load(_ request: URLRequest) async {
        do {
            let credential = try await PanelSessionCoordinator.shared.credential()
            let firstResponse = try await response(for: request, credential: credential)
            
            if firstResponse.statusCode == 401 {
                let refreshedCredential = try await PanelSessionCoordinator.shared.credential(forceRefresh: true)
                let retryResponse = try await response(for: request, credential: refreshedCredential)
                complete(with: retryResponse)
                return
            }
            
            complete(with: firstResponse)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    private func response(for request: URLRequest, credential: PanelSessionCredential) async throws -> PanelSessionURLProtocolResponse {
        var request = request
        request.setValue(credential.cookieHeader, forHTTPHeaderField: "Cookie")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        return PanelSessionURLProtocolResponse(
            data: data,
            response: response,
            statusCode: statusCode
        )
    }
    
    private func complete(with response: PanelSessionURLProtocolResponse) {
        client?.urlProtocol(self, didReceive: response.response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: response.data)
        client?.urlProtocolDidFinishLoading(self)
    }
}

nonisolated final class PanelSessionURLProtocolLoader: @unchecked Sendable {
    private weak var urlProtocol: PanelSessionURLProtocol?
    private let request: URLRequest
    
    init(urlProtocol: PanelSessionURLProtocol, request: URLRequest) {
        self.urlProtocol = urlProtocol
        self.request = request
    }
    
    func load() async {
        await urlProtocol?.load(request)
    }
}

nonisolated struct PanelSessionURLProtocolResponse {
    let data: Data
    let response: URLResponse
    let statusCode: Int
}

nonisolated func deletePanelSession() {
    PanelSessionStore.delete()
    
    Task {
        await PanelSessionCoordinator.shared.clear()
    }
}

func logoutPanelSessionIfPossible() async {
    guard let credential = PanelSessionStore.load() else {
        return
    }
    
    let baseURL = credential.baseURL ?? CalagopusClient.defaultBaseURL
    let client = CalagopusClient(baseURL: baseURL, session: PanelSessionURLProtocol.session)
    
    do {
        let endpoint = try client.endpoint(for: CalagopusGeneratedOperations.postApiClientAccountLogout)
        let response = try await client.response(for: endpoint)
        Logger().info("\(response.statusCode) • panelSessionLogout")
    } catch {
        Logger().error("Panel session logout failed: \(error.localizedDescription)")
    }
    
    deletePanelSession()
}
#endif
