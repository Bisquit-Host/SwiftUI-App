import Foundation

struct Converter {
    static func millisecondsToTime(_ milliseconds: Int) -> String {
        guard milliseconds != 0 else {
            return "-"
        }
        
        let totalSeconds = milliseconds / 1000
        let days = totalSeconds / (24 * 3600)
        let hours = (totalSeconds % (24 * 3600)) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if days > 0 {
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}
