import Foundation
import Observation

@Observable
final class PanelSignInVM {
    private(set) var authorization: BillingOIDCPendingAuthorization?
    private(set) var isApproving = false
    private(set) var errorMessage = ""
    var isShowingConfirmation = false
    var isShowingError = false
    
    private var pendingRequestID: String?
    private var isLoading = false
    private let api = BillingOIDCAuthorizationAPI()
    
    var confirmationTitle: String {
        guard let authorization else {
            return "Sign in to Calagopus"
        }
        
        return "Sign in to \(authorization.clientName)"
    }
    
    var confirmationMessage: String {
        guard let authorization else {
            return "Allow this sign-in request"
        }
        
        let scopes = authorization.scopes.joined(separator: ", ")
        let destination = URL(string: authorization.redirectURI)?.host ?? authorization.clientName
        return "Bisquit Host will share \(scopes) and return you to \(destination)"
    }
    
    @discardableResult
    func handle(_ url: URL, accessToken: String?) -> Bool {
        guard let requestID = PanelSignInURL.requestID(from: url) else {
            return false
        }
        
        if pendingRequestID == requestID, isLoading || authorization != nil {
            return true
        }
        
        pendingRequestID = requestID
        authorization = nil
        isShowingConfirmation = false
        resume(accessToken: accessToken)
        return true
    }
    
    func resume(accessToken: String?) {
        guard accessToken?.isEmpty == false,
              let pendingRequestID,
              authorization == nil,
              !isLoading
        else {
            return
        }
        
        isLoading = true
        
        Task {
            await loadAuthorization(requestID: pendingRequestID)
        }
    }
    
    func approve(accessToken: String?) async -> URL? {
        guard !isApproving,
              let requestID = pendingRequestID,
              let authorization,
              let accessToken,
              !accessToken.isEmpty
        else {
            return nil
        }
        
        isApproving = true
        defer { isApproving = false }
        
        do {
            let decision = try await api.approve(requestID: requestID, accessToken: accessToken)
            let redirectURL = try validatedRedirectURL(decision.redirectURL, authorization: authorization)
            clear()
            return redirectURL
        } catch {
            showError(error)
            isShowingConfirmation = true
            return nil
        }
    }
    
    func cancel() {
        clear()
    }
    
    private func loadAuthorization(requestID: String) async {
        defer { isLoading = false }
        
        do {
            let authorization = try await api.pendingAuthorization(requestID: requestID)
            guard pendingRequestID == requestID else {
                return
            }
            
            self.authorization = authorization
            isShowingConfirmation = true
        } catch {
            guard pendingRequestID == requestID else {
                return
            }
            
            pendingRequestID = nil
            showError(error)
        }
    }
    
    private func validatedRedirectURL(
        _ value: String,
        authorization: BillingOIDCPendingAuthorization
    ) throws -> URL {
        guard let redirectURL = URL(string: value),
              redirectURL.scheme == "https",
              redirectURL.host != nil,
              redirectURL.user == nil,
              redirectURL.password == nil,
              let expectedURL = URL(string: authorization.redirectURI),
              redirectURL.scheme == expectedURL.scheme,
              redirectURL.host == expectedURL.host,
              redirectURL.port == expectedURL.port,
              redirectURL.path == expectedURL.path
        else {
            throw BillingOIDCAuthorizationError.invalidRedirectURL
        }
        
        let queryItems = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard queryItems.contains(where: { $0.name == "code" && $0.value?.isEmpty == false }),
              queryItems.contains(where: { $0.name == "state" && $0.value?.isEmpty == false })
        else {
            throw BillingOIDCAuthorizationError.invalidRedirectURL
        }
        
        return redirectURL
    }
    
    private func clear() {
        pendingRequestID = nil
        authorization = nil
        isShowingConfirmation = false
    }
    
    private func showError(_ error: Error) {
        errorMessage = error.localizedDescription
        isShowingError = true
    }
}
