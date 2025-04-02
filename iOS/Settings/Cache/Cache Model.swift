import SwiftUI

extension CacheLimit {
    enum CacheLimit: String, Identifiable {
        case MB250 = "250 MB",
             GB1 = "1 GB"
        
        var id: String {
            self.rawValue
        }
        
        var loc: LocalizedStringKey {
            switch self {
            case .MB250: "250 MB"
            case .GB1: "1 GB"
            }
        }
    }
}

extension CacheExpiration {
    enum CacheExpiration: String {
        case day, week, month, year, never
        
        var loc: LocalizedStringKey {
            switch self {
            case .day: "Day"
            case .week: "Week"
            case .month: "Month"
            case .year: "Year"
            case .never: "Never"
            }
        }
    }
}
