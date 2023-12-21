import ScrechKit
import PteroNet

@Observable
final class LogVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var searchField = ""
    var logs: [LogsData] = []
    var searchedLogs: [LogsData] {
        guard !searchField.isEmpty else {
            return logs
        }
        
        let prompt = searchField.lowercased()
        
        return logs.filter {
            $0.attributes.relationships.actor.attributes?.username
                .lowercased().contains(prompt) ?? false ||
            $0.attributes.relationships.actor.attributes?.email
                .lowercased().contains(prompt) ?? false
        }
    }
    
    func fetchLogs() {
        getLogsAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    withAnimation {
                        self.logs = model
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
