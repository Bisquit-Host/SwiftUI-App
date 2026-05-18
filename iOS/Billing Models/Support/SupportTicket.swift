import BisquitoNet
import SwiftUI

extension SupportTicketStatus {
    var color: Color {
        switch self {
        case .new: .green
        case .awaitingAdmin, .awaitingUser: .orange
        case .closed: .gray
        }
    }
    
    var loc: String {
        switch self {
        case .new: String(localized: "New")
        case .awaitingAdmin: String(localized: "Awaiting admin response")
        case .awaitingUser: String(localized: "Answered")
        case .closed: String(localized: "Closed")
        }
    }
}
