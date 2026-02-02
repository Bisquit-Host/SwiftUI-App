import Foundation

@Observable
final class MetricListVM {
    var files: [URL] = []
    
    func modificationDate(_ url: URL) -> Date? {
        let values = try? url.resourceValues(forKeys: [.contentModificationDateKey])
        return values?.contentModificationDate
    }
    
    func loadFiles() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            files = []
            return
        }
        
        let metricsDirectory = documentsURL.appendingPathComponent("Metrics")
        
        let directoryContents = (try? FileManager.default.contentsOfDirectory(at: metricsDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles)) ?? []
        
        files = directoryContents.sorted { lhs, rhs in
            let lhsDate = modificationDate(lhs) ?? .distantPast
            let rhsDate = modificationDate(rhs) ?? .distantPast
            return lhsDate > rhsDate
        }
    }

    /// Returns files grouped by day (most recent day first, files newest-first inside each day)
    func filesByDay() -> [(day: Date, files: [URL])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: files) { url in
            calendar.startOfDay(for: modificationDate(url) ?? .distantPast)
        }

        let sortedDays = grouped.keys.sorted(by: >)
        return sortedDays.map { day in
            let urls = (grouped[day] ?? []).sorted { lhs, rhs in
                let lhsDate = modificationDate(lhs) ?? .distantPast
                let rhsDate = modificationDate(rhs) ?? .distantPast
                return lhsDate > rhsDate
            }
            return (day: day, files: urls)
        }
    }
}
