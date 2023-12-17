import ScrechKit
import PteroNet

@Observable
final class ApikeyVM {
    var keys: [ApiKeyListData] = []
    
    func fetchKeys() {
        getApiKeyList() { result in
            switch result {
            case .success(let model):
                if let model {
                    withAnimation {
                        self.keys = model.data
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func create(_ identifier: String) {
        createApiKey(identifier) { result in
            switch result {
            case .success(let model):
                if let model {
                    let id = model.attributes.id
                    
                    if let meta = model.meta {
                        UIPasteboard.general.string = id + meta.token
                        
                        SystemAlert.copied()
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func delete(
        _ identifier: String
    ) {
        deleteApiKey(identifier) { _ in
            
        }
    }
}
