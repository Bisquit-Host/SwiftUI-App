import Foundation

struct BillingOIDCAuthorizationAPI {
    private static let baseURL = "https://api.bisquit.host/oidc/authorize/requests"

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func pendingAuthorization(requestID: String) async throws -> BillingOIDCPendingAuthorization {
        let request = try request(requestID: requestID)
        return try await response(for: request)
    }

    func approve(requestID: String, accessToken: String) async throws -> BillingOIDCAuthorizationDecision {
        var request = try request(requestID: requestID, action: "approve")
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return try await response(for: request)
    }

    private func request(requestID: String, action: String? = nil) throws -> URLRequest {
        guard var url = URL(string: Self.baseURL) else {
            throw BillingOIDCAuthorizationError.invalidURL
        }

        url.append(path: requestID)

        if let action {
            url.append(path: action)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func response<Response: Decodable>(for request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BillingOIDCAuthorizationError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw BillingOIDCAuthorizationError.requestFailed(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(Response.self, from: data)
    }
}
