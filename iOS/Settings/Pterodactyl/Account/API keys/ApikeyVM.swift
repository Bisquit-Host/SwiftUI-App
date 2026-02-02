import ScrechKit
import PteroNet

@Observable
final class ApikeyVM {
    var keys: [ApiKeyListData] = []
    //    var showProgress = false
    
    func fetchKeys() async {
        do {
            keys = try await apiKeyListAPI()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func create(_ identifier: String, onSuccess: @escaping () -> Void) async {
        do {
            let model = try await apiKeyCreateAPI(identifier)
            let id = model.attributes.id
            let token = model.meta?.token
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
            try await apiKeyDeleteAPI(identifier)
        } catch {
            SystemAlert.error(error)
        }
        
        await fetchKeys()
    }
}
