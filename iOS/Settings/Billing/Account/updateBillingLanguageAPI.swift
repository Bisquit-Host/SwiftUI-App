import BisquitoNet
import Foundation
import OSLog

func updateBillingLanguageAPI(
    language: BillingLanguage,
    accessToken: String,
    onBillingError: @MainActor @escaping (String, String?) -> Void = { _, _ in }
) async -> PatchUserResponse? {
    guard let url = URL(string: "https://api.bisquit.host/user/settings/lang") else {
        Logger().error("Invalid URL")
        onBillingError("Invalid URL", nil)
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONEncoder().encode(["lang": language.rawValue])
    
    do {
        let (data, res) = try await URLSession.shared.data(for: request)
        
        if decodeBillingError(data, with: res, in: #function, onDecode: { @MainActor title, subtitle in
            onBillingError(title, subtitle)
        }) {
            return nil
        }
        
        guard let http = res as? HTTPURLResponse else {
            onBillingError("No response", nil)
            return nil
        }
        
        guard (200...299).contains(http.statusCode) else {
            onBillingError("Request failed", "Unexpected status code \(http.statusCode)")
            return nil
        }
        
        return try JSONDecoder().decode(PatchUserResponse.self, from: data)
    } catch {
        Logger().error("\(error.localizedDescription)")
        onBillingError("Request failed", error.localizedDescription)
        return nil
    }
}
