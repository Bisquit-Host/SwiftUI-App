import Foundation
import PteroNet

@Observable
final class PluginVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var plugins: [Plugin] = []
    
    func fetchPlugins() {
        pluginListAPI(id, printResponse: true) { result in
            switch result {
            case .success(let model):
                if let model {
                    self.plugins = model
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
