//import Intents
//
//class IntentHandler: INExtension {
//
//    override func handler(for intent: INIntent) -> Any {
//        // This is the default implementation.  If you want different objects to handle different intents,
//        // you can override this and return the handler you want for that particular intent.
//
//        return self
//    }
//
//}

import Intents

class IntentHandler: INExtension, CryptoPriceConfigurationIntentHandling {
    func provideSelectedCryptoOptionsCollection(
        for intent: CryptoPriceConfigurationIntent
    ) async throws -> INObjectCollection<Crypto> {
        
        // Fetch
        let assets = try await AssetFetcher.fetchTopTenAssets()
        
        let servers = assets.map { asset in
            let server = Crypto(
                identifier: asset.id,
                display: "\(asset.name) (\(asset.id))"
            )
            
            server.id = asset.id
            server.name = asset.name
            
            return server
        }
        
        // Create a collection with the array of cryptos
        let collection = INObjectCollection(items: servers)
        
        // Return the collections
        return collection
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation. If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent
        
        self
    }
}
