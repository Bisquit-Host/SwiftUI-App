import ScrechKit
import PteroNet

@Observable
final class LogVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var searchField = ""
    private var logs: [LogAttributes] = []
    
    var searchedLogs: [LogAttributes] {
        guard !searchField.isEmpty else {
            return logs
        }
        
        let prompt = searchField.lowercased()
        
        return logs.filter {
            $0.relationships.actor.attributes?.username
                .lowercased().contains(prompt) ?? false ||
            $0.relationships.actor.attributes?.email
                .lowercased().contains(prompt) ?? false
        }
    }
    
    func fetchLogs(_ prefetch: Bool = false) {
        logListAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        self.logs = model.map(\.attributes)
                    }
                    
                    if prefetch {
                        self.prefetchActorImages()
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func prefetchActorImages() {
        let uniqueImages = Array(Set(self.logs.compactMap { log in
            let image = log.relationships.actor.attributes?.image
            
            if let image, let url = URL(string: image) {
                return url
            }
            
            return nil
        }))
        
        prefetchImages(uniqueImages)
    }
}
