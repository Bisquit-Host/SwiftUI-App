import PteroNet

struct WidgetServerListResponse: Decodable {
    let data: [WidgetServer]
}

struct WidgetServer: Decodable {
    let attributes: WidgetServerAttributes
}

struct WidgetServerAttributes: Decodable {
    let identifier: String
    let name: String
}

struct Asset: Codable {
    let id: String
    let name: String
    let symbol: String
}

struct AssetDetails: Codable {
    let priceUsd: String
    
    /// Formatted price value
    var price: String {
        let value = Double(priceUsd) ?? 0
        
        return "$" + String(format: "%.2f", value)
    }
}

struct AssetFetcher {
    private struct Response<T: Codable>: Codable {
        let data: T
    }
    
    static func fetchTopTenAssets() async throws -> [Asset] {
        do {
            let url = URL(string: "https://mgr.bisquit.host/api/client")!
            
            // Create a mutable URLRequest
            var request = URLRequest(url: url)
            
            // Fetch the API key from the Keychain
            if let apiKey = Keychain.load(key: "selectedApiKey") {
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            } else {
                print("Error fetching value from Keychain")
                // Return the test asset if the API key is missing
                return [
                    .init(id: "Bitcoin", name: "BTC", symbol: "$10000")
                ]
            }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(WidgetServerListResponse.self, from: data)
            
            var assets: [Asset] = []
            
            for server in response.data.map(\.attributes) {
                let asset = Asset(
                    id: "",
                    name: server.name,
                    symbol: server.identifier
                )
                
                assets.append(asset)
            }
            
            return assets
            
        } catch {
            let testAssets: [Asset] = [
                .init(id: "", name: error.localizedDescription, symbol: "Error")
            ]
            
            return testAssets
        }
    }
    
    static func fetchAssetDetails(_ id: String) async throws -> AssetDetails {
        let url = URL(string: "https://api.coincap.io/v2/assets/\(id)")!
        
        // Fetch JSON
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse JSON
        let response = try JSONDecoder().decode(Response<AssetDetails>.self, from: data)
        
        let assetDetails = response.data
        
        return assetDetails
    }
}
