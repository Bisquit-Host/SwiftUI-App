import ScrechKit
import Calagopus

@Observable
final class ApikeyVM {
    var keys: [CalagopusAPIKey] = []
    //    var showProgress = false
    
    func fetchKeys() async {
        do {
            keys = try await CalagopusClientFactory.client().apiKeys().data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func create(_ identifier: String, onSuccess: @escaping () -> Void) async {
        do {
            let response = try await CalagopusClientFactory.client().createAPIKey(name: identifier)
            let id = response.apiKey.id
            let token = response.secretToken
#if !os(tvOS)
            if let token {
                Pasteboard.copy(id + token)
#if !os(macOS)
                SystemAlert.copied()
#endif
            }
#endif
            await fetchKeys()
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func delete(_ identifier: String) async {
        do {
            try await CalagopusClientFactory.client().deleteAPIKey(id: identifier)
        } catch {
            SystemAlert.error(error)
        }
        
        await fetchKeys()
    }
}
