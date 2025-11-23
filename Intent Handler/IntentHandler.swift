import Intents

class IntentHandler: INExtension, CryptoPriceConfigurationIntentHandling {
    func provideSelectedServerOptionsCollection(for intent: CryptoPriceConfigurationIntent) async throws -> INObjectCollection<Crypto> {
        let servers = await Networking.fetchServers().map {
#warning("Fetch image")
            // let image = INImage(imageData: ...)
            
            Crypto(identifier: $0.id, display: $0.name, subtitle: $0.id, image: nil)
        }
        
        return INObjectCollection(items: servers)
    }
    
    override func handler(for intent: INIntent) -> Any {
        self
    }
}
