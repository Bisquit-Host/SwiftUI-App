import SwiftUI
import BisquitoNet

struct AdminTicketSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let ticket: SupportTicketDTO
    let adminUserID: Int
    let accessToken: String

    var body: some View {
        NavigationStack {
            TicketDetails(ticket, adminUserID: adminUserID, adminAccessToken: accessToken)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done", systemImage: "xmark") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
