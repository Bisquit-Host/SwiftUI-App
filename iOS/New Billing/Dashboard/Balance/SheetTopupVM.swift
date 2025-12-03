import Foundation

@Observable
final class SheetTopupVM {
    var operations: [BillingOperation] = []
    var isLoading = false
    var isTopupLoading = false
    
    private let baseURL = "https://test-api.bisquit.host"
    
    struct TopupResponse: Decodable {
        let url: String
    }
    
    private struct TopupRequest: Encodable {
        let amount: Double
        let method: String?
    }
    
    func fetchOperations(accessToken: String) async {
        guard !accessToken.isEmpty else {
            print("Missing access token")
            return
        }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        guard let url = URL(string: "\(baseURL)/finances/operations") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse {
                print("Billing operations status:", http.statusCode)
                
                if http.statusCode == 401 {
                    SystemAlert.error("Unauthorized", subtitle: "401")
                    return
                }
                
                if http.statusCode == 204 {
                    operations = []
                    return
                }
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: pretty, encoding: .utf8) {
                print("Operations response:\\n\(prettyString)")
                
            } else if let raw = String(data: data, encoding: .utf8) {
                print("Operations raw response:\\n\(raw)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            operations = try decoder.decode(BillingOperationsResponse.self, from: data).operations
        } catch {
            print("❌ Error fetching operations")
            SystemAlert.error("Error", subtitle: error.localizedDescription)
        }
    }
    
    func createTopup(accessToken: String, amount: Double, method: String?, currency: String) async -> URL? {
        guard !accessToken.isEmpty else {
            SystemAlert.error("Missing token", subtitle: "Please sign in again")
            return nil
        }
        
        guard let url = URL(string: "\(baseURL)/finances/topup") else {
            SystemAlert.error("Invalid URL")
            return nil
        }
        
        if amount < minimumAmount(for: currency) {
            SystemAlert.error("Amount too small")
            return nil
        }
        
        isTopupLoading = true
        defer { isTopupLoading = false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(TopupRequest(amount: amount, method: method?.lowercased()))
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse {
                print("Topup status:", http.statusCode)
                
                if http.statusCode == 401 {
                    SystemAlert.error("Unauthorized", subtitle: "401")
                    return nil
                }
                
                if http.statusCode >= 400 {
                    if let raw = String(data: data, encoding: .utf8) {
                        SystemAlert.error("Top up failed", subtitle: raw)
                    } else {
                        SystemAlert.error("Top up failed", subtitle: http.statusCode.description)
                    }
                    return nil
                }
            }
            
            let topup = try JSONDecoder().decode(TopupResponse.self, from: data)
            
            guard let paymentURL = URL(string: topup.url) else {
                SystemAlert.error("Invalid payment URL")
                return nil
            }
            
            return paymentURL
        } catch {
            print("❌ Topup failed")
            SystemAlert.error("Error", subtitle: error.localizedDescription)
            return nil
        }
    }
    
    private func minimumAmount(for currency: String) -> Double {
        currency.uppercased() == "RUB" ? 50 : 1
    }
}
