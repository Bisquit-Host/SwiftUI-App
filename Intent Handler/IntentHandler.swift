import Intents

class IntentHandler: INExtension, CryptoPriceConfigurationIntentHandling {
    func provideSelectedServerOptionsCollection(
        for intent: CryptoPriceConfigurationIntent
    ) async throws -> INObjectCollection<Crypto> {
        let servers = await Networking.fetchServers().map {
#warning("Fetch image")
            // let image = INImage(imageData: ...)
            
            let server = Crypto(
                identifier: $0.id,
                display: $0.name,
                subtitle: $0.id,
                image: nil
            )
            
            server.id = $0.id
            server.name = $0.name
            
            return server
        }
        
        return INObjectCollection(items: servers)
    }
    
    override func handler(for intent: INIntent) -> Any {
        self
    }
}
