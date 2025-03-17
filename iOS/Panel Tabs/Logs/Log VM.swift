import ScrechKit
import PteroNet

@Observable
final class LogVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var logs: [LogAttributes] = []
    
    var loggedUserCount: Int {
        Set(logs.map(\.relationships.actor)).count
    }
    
    var daysLogged: Int? {
        guard
            let firstDate = logs.last?.timestamp,
            let firstLoggedDate = dateFormatter.date(from: firstDate)
        else {
            return nil
        }
        
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: firstLoggedDate, to: Date()).day
    }
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        
        formatter.formatOptions = [
            .withInternetDateTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime
        ]
        
        return formatter
    }()
    
    var logsByMonth: [Array<LogAttributes>.SubSequence] {
        logs.chunked { lhs, rhs in
            let date1 = dateFormatter.date(from: lhs.timestamp)
            let date2 = dateFormatter.date(from: rhs.timestamp)
            
            return Calendar.current.component(.month, from: date1!) == Calendar.current.component(.month, from: date2!)
        }
    }
    
    func monthName(for isoTimestamp: String) -> String {
        guard let date = dateFormatter.date(from: isoTimestamp) else {
            return "Unknown Month"
        }
        
        return DateFormatter()
            .monthSymbols[Calendar.current.component(.month, from: date) - 1]
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
