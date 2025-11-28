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
}
