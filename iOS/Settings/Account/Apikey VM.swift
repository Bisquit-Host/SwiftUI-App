import ScrechKit
import PteroNet

@Observable
final class ApikeyVM {
    var keys: [ApiKeyListData] = []
    //    var showProgress = false
    
    func fetchKeys() {
        apiKeyListAPI { result in
            switch result {
            case .success(let model):
                if let model {
                    self.keys = model.data
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func create(_ identifier: String, onSuccess: @escaping () -> Void) {
        apiKeyCreateAPI(identifier) { result in
            switch result {
            case .success(let model):
                if let model {
                    let id = model.attributes.id
                    
                    if let meta = model.meta {
                        main {
                            UIPasteboard.general.string = id + meta.token
                            
                            SystemAlert.copied()
                        }
                    }
                    
                    self.fetchKeys()
                    
                    onSuccess()
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func delete(_ identifier: String) {
        apiKeyDeleteAPI(identifier) { result in
            switch result {
            case .success:
                break
                
            case .failure(let error):
                SystemAlert.error(error)
            }
            
            self.fetchKeys()
        }
    }
}
