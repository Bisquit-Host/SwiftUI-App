import ScrechKit
import Calagopus

@Observable
final class CalagopusAPIKeyVM {
    private(set) var keys: [CalagopusAPIKey] = []
    
    func fetchKeys() async {
        do {
            keys = try await CalagopusClientFactory.client().apiKeys().data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func create(_ name: String, onSuccess: @escaping () -> Void) async {
        do {
            let response = try await CalagopusClientFactory.client().createAPIKey(name: name)
            
            if let token = response.secretToken {
                Pasteboard.copy(response.apiKey.id + token)
                SystemAlert.copied()
            }
            
            await fetchKeys()
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func delete(_ id: String) async {
        do {
            try await CalagopusClientFactory.client().deleteAPIKey(id: id)
            
            if let index = keys.firstIndex(where: { $0.id == id }) {
                keys.remove(at: index)
            } else {
                await fetchKeys()
            }
        } catch {
            SystemAlert.error(error)
        }
    }
}
