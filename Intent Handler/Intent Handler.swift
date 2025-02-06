import Intents

class IntentHandler: INExtension, CryptoPriceConfigurationIntentHandling {
    func provideSelectedServerOptionsCollection(
        for intent: CryptoPriceConfigurationIntent,
        with completion: @escaping (INObjectCollection<Crypto>?, Error?) -> Void
    ) {
        Task {
            do {
                let servers = try await Networking.fetchServers().map {
#warning("Fetch image")
                    // let image = INImage(imageData: <#T##Data#>)
                    
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
