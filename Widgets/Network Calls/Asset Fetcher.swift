import PteroNet

struct AssetFetcher {
    static func fetchTopTenAssets() async throws -> [Asset] {
        var assets: [Asset] = []
        
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
            
            for server in response.data.map(\.attributes) {
                let asset = Asset(
                    id: server.identifier,
                    name: server.name
                )
                
                assets.append(asset)
            }
        } catch {
            let errorAsset = Asset(id: "69.2", name: error.localizedDescription)
            
            assets.append(errorAsset)
        }
        
        return assets
    }
    
    static func fetchAssetDetails(_ id: String) async -> AssetDetails {
        let assetDetails: AssetDetails
        
        do {
            guard let request = URLRequest(
                path: "client/servers/\(id)/resources"
            ) else {
                return AssetDetails(state: "Error creating request")
            }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let json = try JSONDecoder().decode(WWResourceUsageResponse.self, from: data)
            let state = json.attributes.current_state
            
            assetDetails = AssetDetails(
                state: state
            )
        } catch {
            assetDetails = AssetDetails(
                state: error.localizedDescription
            )
        }
        
        return assetDetails
    }
}
