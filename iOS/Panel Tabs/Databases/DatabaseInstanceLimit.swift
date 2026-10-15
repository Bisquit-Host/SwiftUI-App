import ScrechKit

enum DatabaseInstanceLimit {
    static func megabytes(_ megabytes: Int64, countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        guard megabytes != 0 else {
            return String(localized: "Unlimited")
        }
        
        return formatBytes(megabytes * 1024 * 1024, countStyle: countStyle)
    }
    
    static func cpu(_ percent: Int) -> String {
        guard percent != 0 else {
            return String(localized: "Unlimited")
        }
        
        return percent.formatted(.percent.scale(1))
    }
}
