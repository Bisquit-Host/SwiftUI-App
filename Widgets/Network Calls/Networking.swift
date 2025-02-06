import PteroNet

struct Networking {
    static func fetchServers() async throws -> [Asset] {
        try await withCheckedThrowingContinuation { continuation in
            serverListAPI { result in
                switch result {
                case .success(let model):
                    guard let model = model?.data else {
                        continuation.resume(throwing: NSError(domain: "NoData", code: -1, userInfo: nil))
                        return
                    }
                    
                    var assets: [Asset] = []
                    
                    for server in model.map(\.attributes) {
                        let asset = Asset(
                            id: server.id,
                            name: server.name
                        )
                        
                        assets.append(asset)
                    }
                    
                    continuation.resume(returning: assets)
                    
                case .failure(let error):
                    continuation.resume(returning: [
                        Asset(id: "69.2", name: error.localizedDescription)
                    ])
                }
            }
        }
    }
    
    static func fetchResourceUsage(_ id: String) async throws -> AssetDetails {
        try await withCheckedThrowingContinuation { continuation in
            serverUsageAPI(id) { result in
                switch result {
                case .success(let model):
                    guard let model else {
                        continuation.resume(returning: AssetDetails(
                            state: "No data"
                        ))
                        
                        return
                    }
                    
                    let state = model.attributes.state
                    
                    let assetDetails = AssetDetails(
                        state: state,
                        test: model.attributes
                    )
                    
                    continuation.resume(returning: assetDetails)
                    
                case .failure(let error):
                    continuation.resume(returning: AssetDetails(
                        state: error.localizedDescription
                    ))
                }
            }
        }
    }
}
