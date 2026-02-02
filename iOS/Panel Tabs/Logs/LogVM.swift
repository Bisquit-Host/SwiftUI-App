import SwiftUI
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
        if let selectedActor {
            logs.filter {
                $0.relationships == selectedActor
            }
        } else {
            logs
        }
    }
    
    var searchedLogs: [LogAttributes] {
        if searchPrompt.isEmpty {
            filteredLogs
        } else {
            filteredLogs.filter {
                $0.event.localizedStandardContains(searchPrompt)
            }
        }
    }
    
    var daysLogged: Int? {
        guard let firstDate = searchedLogs.last?.timestamp else {
            return nil
        }
        
        return Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day
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
            return Calendar.current.component(.month, from: lhs.timestamp) == Calendar.current.component(.month, from: rhs.timestamp)
        }
    }
    
    func monthName(for date: Date) -> String {
        DateFormatter()
            .monthSymbols[Calendar.current.component(.month, from: date) - 1]
    }
    
    func fetchLogs(_ prefetch: Bool = false) async {
        do {
            self.logs = try await logListAPI(id)
            
            if prefetch {
                prefetchActorImages()
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
        
        Prefetcher.prefetchImages(uniqueImages)
    }
}
