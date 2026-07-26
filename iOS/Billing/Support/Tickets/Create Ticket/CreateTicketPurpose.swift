import ScrechKit

enum CreateTicketPurpose {
    case standard, accountRemoval, testAccess

    var navigationTitle: LocalizedStringKey {
        switch self {
        case .standard: "New Ticket"
        case .accountRemoval: "Request account removal"
        case .testAccess: "Request test access"
        }
    }

    var initialTitle: String {
        switch self {
        case .standard: ""
        case .accountRemoval: "Request account removal"
        case .testAccess: "Request test access"
        }
    }

    var showsTitleSection: Bool {
        self == .standard
    }

    var isMessageRequired: Bool {
        self != .accountRemoval
    }

    var areAttachmentsOptional: Bool {
        self != .standard
    }
}
