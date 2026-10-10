import SwiftUI
import Calagopus

@Observable
final class LogVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var logs: [CalagopusServerLog] = []
    var searchPrompt = ""
    var selectedActor: CalagopusLogRelationships? = nil
    
    var loggedUserCount: Int {
        Set(searchedLogs.map(\.relationships.actor)).count
    }
    
    var actors: [CalagopusLogRelationships?] {
        Array(Set(
            logs.compactMap(\.relationships)
        )).sorted {
            $0.actor.attributes?.username ?? "" < $1.actor.attributes?.username ?? ""
        }
    }
    
    var filteredLogs: [CalagopusServerLog] {
        if let selectedActor {
            logs.filter {
                $0.relationships == selectedActor
            }
        } else {
            logs
        }
    }
    
    var searchedLogs: [CalagopusServerLog] {
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
    
    var logsByMonth: [Array<CalagopusServerLog>.SubSequence] {
        searchedLogs.chunked { lhs, rhs in
            return Calendar.current.component(.month, from: lhs.timestamp) == Calendar.current.component(.month, from: rhs.timestamp)
        }
    }
    
    func monthName(for date: Date, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        let month = formatter.calendar.component(.month, from: date)

        return formatter.standaloneMonthSymbols[month - 1].capitalized(with: locale)
    }
    
    func fetchLogs(_ prefetch: Bool = false) async {
        do {
            self.logs = try await CalagopusNet.client().serverLogs(server: id)
            
            if prefetch {
                prefetchActorImages()
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func prefetchActorImages() {
        let uniqueImages = Array(Set(self.logs.compactMap { log in
            Self.actorImageURL(log.relationships.actor.attributes?.image)
        }))
        
        Prefetcher.prefetchImages(uniqueImages)
    }

    static func actorImageURL(_ image: String?) -> URL? {
        let baseURL = (try? CalagopusNet.client())?.baseURL ?? CalagopusClient.defaultBaseURL
        return actorImageURL(image, relativeTo: baseURL)
    }

    static func actorImageURL(_ image: String?, relativeTo baseURL: URL) -> URL? {
        guard let image else { return nil }
        let path = image.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !path.isEmpty,
              let url = URL(string: path, relativeTo: baseURL)?.absoluteURL,
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              url.host != nil else {
            return nil
        }

        return url
    }
}
