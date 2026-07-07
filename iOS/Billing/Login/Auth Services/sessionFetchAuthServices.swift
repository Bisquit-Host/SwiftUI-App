import Foundation

private enum BillingAuthServicesEndpoint {
    static let providers = "https://api.bisquit.host/auth/providers"
}

func sessionFetchAuthServices() async throws -> [BillingAuthService] {
    guard let url = URL(string: BillingAuthServicesEndpoint.providers) else {
        throw URLError(.badURL)
    }
    
    let request = URLRequest(url: url)
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let http = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    
    guard 200..<300 ~= http.statusCode else {
        throw URLError(.badServerResponse)
    }
    
    return try JSONDecoder().decode(BillingAuthServicesResponse.self, from: data).providers
}
