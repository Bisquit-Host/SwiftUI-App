import ScrechKit
import PteroNet

@Observable
final class LinkingVM {
    var errorMessage = ""
    var alertError = false
    
    private let tabMapping: [String: Tabs] = [
        "backups": .backup,
        "files": .files,
        "": .info
    ]
    
    func handleDeepLink(_ navState: NavState,
                        settings: SettingsStorage,
                        url: URL
    ) {
        let components = url.pathComponents
        print(url.description)
        print(components)
        
        guard let index = components.firstIndex(of: "server"),
              index + 1 < components.count else {
            return
        }
        
        let id = components[index + 1]
        let tab = (index + 2 < components.count) ? components[index + 2] : ""
        
        serverDetailsAPI(id) { result in
            switch result {
            case .success:
                let tabOnStart = self.tabMapping[tab] ?? .info
                
                settings.lastTabPanel = tabOnStart
                navState.navigate(.toPanel(id))
                
            case .failure(let error):
                SystemAlert.error(error)
                
                self.errorMessage = error.localizedDescription
                self.alertError = true
            }
        }
    }
}
