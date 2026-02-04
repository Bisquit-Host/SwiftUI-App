import Foundation
import OSLog

private struct TopupRequest: Encodable {
    let amount: Int64
    let gatewayId: String
}

struct TopupResponse: Decodable {
    let url: String
}

func createTopupGatewayAPI(accessToken: String, amount: Int64, gatewayId: String) async -> TopupResponse? {
    guard let url = URL(string: "https://test-api.bisquit.host/finances/topup") else {
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.httpBody = try? JSONEncoder().encode(TopupRequest(amount: amount, gatewayId: gatewayId))
    
    do {
        let (data, res) = try await URLSession.shared.data(for: request)
        
        if let http = res as? HTTPURLResponse {
            Logger().info("\(http.statusCode) • Create topup")
            
            if http.statusCode >= 400 {
                return nil
            }
        }
        
        return try JSONDecoder().decode(TopupResponse.self, from: data)
    } catch {
        Logger().error("Error creating topup: \(error)")
        return nil
    }
}
