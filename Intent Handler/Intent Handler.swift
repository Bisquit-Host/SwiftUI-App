import Intents

//class IntentHandler: INExtension, CryptoPriceConfigurationIntentHandling {
//    func provideSelectedCryptoOptionsCollection(
//        for intent: CryptoPriceConfigurationIntent
//    ) async throws -> INObjectCollection<Crypto> {
//        
//        // Fetch
//        let assets = try await AssetFetcher.fetchTopTenAssets()
//        
//        let servers = assets.map { asset in
//            let server = Crypto(
//                identifier: asset.id,
//                display: "\(asset.name) (\(asset.id))"
//            )
//            
//            server.id = asset.id
//            server.name = asset.name
//            
//            return server
//        }
//        
//        // Create a collection with the array of cryptos
//        let collection = INObjectCollection(items: servers)
//        
//        // Return the collections
//        return collection
//    }
//    
//    override func handler(for intent: INIntent) -> Any {
//        // This is the default implementation. If you want different objects to handle different intents,
//        // you can override this and return the handler you want for that particular intent
//        
//        self
//    }
//}

class IntentHandler: INExtension, CryptoPriceConfigurationIntentHandling {
    func provideSelectedCryptoOptionsCollection(
        for intent: CryptoPriceConfigurationIntent,
        with completion: @escaping (INObjectCollection<Crypto>?, Error?) -> Void
    ) {
        Task {
            do {
                let assets = try await AssetFetcher.fetchTopTenAssets()
                
                let servers = assets.map {
                    let server = Crypto(
                        identifier: $0.id,
                        display: "\($0.name) (\($0.id))"
                    )
                    
                    server.id = $0.id
                    server.name = $0.name
                    
                    return server
                }
                
                let collection = INObjectCollection(items: servers)
                completion(collection, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    override func handler(for intent: INIntent) -> Any {
        self
    }
}
