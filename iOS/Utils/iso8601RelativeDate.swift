import Foundation

func iso8601RelativeDate(_ stringDate: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    guard let date = formatter.date(from: stringDate) else {
        return stringDate
    }
    
    let seconds = Int(Date().timeIntervalSince(date))
    
    if seconds < 60 {
        return "just now"
        
    } else if seconds < 3_600 {
        return "\(seconds / 60)m ago"
        
    } else if seconds < 86_400 {
        return "\(seconds / 3_600)h ago"
        
    } else if seconds < 604_800 {
        return "\(seconds / 86_400)d ago"
        
    } else if seconds < 2_592_000 {
        return "\(seconds / 604_800)w ago"
        
    } else if seconds < 31_536_000 {
        return "\(seconds / 2_592_000)m ago"
        
    } else {
        return "\(seconds / 31_536_000)y ago"
    }
}
