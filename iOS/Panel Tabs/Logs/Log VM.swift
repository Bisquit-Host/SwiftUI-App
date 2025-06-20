import ScrechKit
import PteroNet

@Observable
final class LogVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var logs: [LogAttributes] = []
    var searchPrompt = ""
    var selectedActor: LogRelationships? = nil
    
    var loggedUserCount: Int {
        Set(searchedLogs.map(\.relationships.actor)).count
    }
    
    var actors: [LogRelationships?] {
        Array(Set(
            logs.compactMap(\.relationships)
        )).sorted {
            $0.actor.attributes?.username ?? "" < $1.actor.attributes?.username ?? ""
        }
    }
    
    var filteredLogs: [LogAttributes] {
        guard let selectedActor else {
            return logs
        }
        
        return logs.filter {
            $0.relationships == selectedActor
        }
    }
    
    var searchedLogs: [LogAttributes] {
        guard !searchPrompt.isEmpty else {
            return filteredLogs
        }
        
        return filteredLogs.filter {
            $0.event.localizedStandardContains(searchPrompt)
        }
    }
    
    var daysLogged: Int? {
        guard
            let firstDate = searchedLogs.last?.timestamp,
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
        searchedLogs.chunked { lhs, rhs in
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
    
    func fetchLogs(_ prefetch: Bool = false) async {
        do {
            self.logs = try await logListAPI(id, printResponse: true)
            
            if prefetch {
                self.prefetchActorImages()
            }
        } catch {
            SystemAlert.error(error)
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
