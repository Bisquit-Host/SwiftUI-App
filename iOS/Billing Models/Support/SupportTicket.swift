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
    
    var loc: LocalizedStringKey {
        switch self {
        case .new: "New"
        case .awaitingAdmin: "Awaiting admin response"
        case .awaitingUser: "Answered"
        case .closed: "Closed"
        }
    }
}
