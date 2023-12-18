import ScrechKit
import PteroNet

@Observable
final class LinkingVM {
    var errorMessage = ""
    var alertError = false
    
    private let tabMapping: [String: Tabs] = [
        "backups": .backup,
        "files": .fileManager,
        "": .info
    ]
    
    func handleDeepLink(_ navState: NavState,
                        settings: SettingsStorage,
                        url: URL
    ) {
        let components = url.pathComponents
        
        guard let index = components.firstIndex(of: "server"),
              index + 1 < components.count else {
            return
        }
        
        let id = components[index + 1]
        let tab = (index + 2 < components.count) ? components[index + 2] : ""
        
        serverDetailsAPI(id) { [weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case .success:
                let tabb = self.tabMapping[tab] ?? .info
                
                settings.lastTabPanel = tabb
                navState.navigate(.toPanel(id))
                
            case .failure(let error):
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
                self.alertError = true
            }
        }
    }
}
