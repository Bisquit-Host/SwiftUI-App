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
}

struct AssetDetails: Codable {
    let state: String
}

struct AssetFetcher {
    private struct Response<T: Codable>: Codable {
        let data: T
    }
    
    static func fetchTopTenAssets() async throws -> [Asset] {
        do {
            let url = URL(string: "https://mgr.bisquit.host/api/client")!
            
            var request = URLRequest(url: url)
            
            if let apiKey = Keychain.load(key: "selectedApiKey") {
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            } else {
                print("Error fetching value from Keychain")
                
                return [
                    .init(
                        id: "69.1",
                        name: "Error fetching value from Keychain"
                    )
                ]
            }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(WidgetServerListResponse.self, from: data)
            
            var assets: [Asset] = []
            
            for server in response.data.map(\.attributes) {
                let asset = Asset(
                    id: server.identifier,
                    name: server.name
                )
                
                assets.append(asset)
            }
            
            return assets
            
        } catch {
            let testAssets: [Asset] = [
                .init(id: "69.2", name: error.localizedDescription)
            ]
            
            return testAssets
        }
    }
    
    static func fetchAssetDetails(_ id: String) async -> AssetDetails {
        do {
            guard let request = URLRequest(
                path: "client/servers/\(id)/resources"
            ) else {
                return AssetDetails(state: "Error creating request")
            }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let json = try JSONDecoder().decode(WWResourceUsageResponse.self, from: data)
            let state = json.attributes.current_state
            
            let assetDetails = AssetDetails(
                state: state
            )
            
            return assetDetails
        } catch {
            let assetDetails = AssetDetails(state: "Error: \(error.localizedDescription)")
            
            return assetDetails
        }
    }
}

public struct WWResourceUsageResponse: Codable {
    public let attributes: WWResourceUsageAttributes
}

public struct WWResourceUsageAttributes: Codable {
    public let current_state: String
}
