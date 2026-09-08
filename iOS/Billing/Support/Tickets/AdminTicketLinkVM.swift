import SwiftUI
import BisquitoNet

@Observable
final class AdminTicketLinkVM {
    var ticket: SupportTicketDTO?
    private(set) var adminUserID: Int?
    private(set) var accessToken: String?
    var errorMessage = ""
    var showsError = false
    private var loadTask: Task<Void, Never>?

    func handle(_ url: URL, accessToken: String?) -> Bool {
        guard let ticketID = AdminTicketURL.ticketID(from: url) else { return false }
        reset()
        guard let accessToken, !accessToken.isEmpty else { return true }
        self.accessToken = accessToken

        loadTask = Task {
            let user: BillingUser? = await fetchUserInfoAPI(accessToken: accessToken)
            guard !Task.isCancelled else { return }
            guard let user else {
                showError("Unable to verify your account")
                return
            }
            guard user.role == .admin else { return }
            let ticket = await fetchAdminTicketAPI(ticketId: ticketID, accessToken: accessToken)
            guard !Task.isCancelled else { return }
            guard let ticket else {
                showError("Unable to load this ticket")
                return
            }
            adminUserID = user.id
            self.ticket = ticket
        }
        return true
    }

    func reset() {
        loadTask?.cancel()
        loadTask = nil
        ticket = nil
        adminUserID = nil
        accessToken = nil
        showsError = false
    }

    private func showError(_ message: String) {
        errorMessage = message
        showsError = true
    }
}
