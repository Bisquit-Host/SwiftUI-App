import SwiftUI

struct TicketCardStatus: View {
    private let status: SupportTicketStatus
    
    init(_ status: SupportTicketStatus) {
        self.status = status
    }
    
    var body: some View {
        Text(status.loc)
            .caption(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.12), in: Capsule())
            .foregroundStyle(status.color)
    }
}

//#Preview {
//    TicketCardStatus()
//        .darkSchemePreferred()
//}
