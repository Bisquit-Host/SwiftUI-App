import Foundation
import OSLog

func fetchPaymentProvidersAPI(accessToken: String) async -> [PaymentGatewayInfo]? {
    guard let url = URL(string: "https://api.bisquit.host/finances/payment-gateways") else {
        return nil
    }
    
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    do {
        let (data, res) = try await URLSession.shared.data(for: request)
        logPrettyJSON(data)
        
        if let http = res as? HTTPURLResponse {
            Logger().info("\(http.statusCode) • Fetch payment providers")
            
            if http.statusCode == 204 {
                return []
            }
            
            if http.statusCode >= 400 {
                return nil
            }
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(PaymentGatewaysResponse.self, from: data).gateways
    } catch {
        Logger().error("Error fetching payment providers: \(error)")
        return nil
    }
}

private func logPrettyJSON(_ data: Data) {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        
        if let prettyJson = String(data: prettyData, encoding: .utf8) {
            Logger().info("Payment gateways JSON: \(prettyJson)")
        }
    } catch {
        if let raw = String(data: data, encoding: .utf8) {
            Logger().info("Payment gateways JSON (raw): \(raw)")
        }
    }
}
