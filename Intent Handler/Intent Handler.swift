import Intents

class IntentHandler: INExtension, CryptoPriceConfigurationIntentHandling {
    func provideSelectedCryptoOptionsCollection(
        for intent: CryptoPriceConfigurationIntent
    ) async throws -> INObjectCollection<Crypto> {
        
        // Fetch
        let assets = try await AssetFetcher.fetchTopTenAssets()
        
        let cryptos = assets.map { asset in
            let crypto = Crypto(
                identifier: asset.id,
                display: "\(asset.name) (\(asset.id))"
            )
            
            crypto.id = asset.id
            crypto.name = asset.name
            
            return crypto
        }
        
        // Create a collection with the array of cryptos
        let collection = INObjectCollection(items: cryptos)
        
        // Return the collections
        return collection
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation. If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent
        
        self
    }
}
