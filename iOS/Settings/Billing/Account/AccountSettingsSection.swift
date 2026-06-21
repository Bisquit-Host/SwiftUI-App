import SwiftUI
import Calagopus
import BisquitoNet

struct AccountSettingsSection: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    @State private var ticketVM = TicketListVM()
    
    private let user: BillingUser?
    
    init(_ user: BillingUser?) {
        self.user = user
    }
    
    var body: some View {
        @Bindable var ticketVM = ticketVM
        
        BillingSectionCard("Account") {
            if let user {
                AccountSettingsHeader(user)
                
                Divider()
                
                AccountSettingsChangeEmail(user)
                AccountSettingsRename(user)
                
                GlassyButton("Language", subtitle: user.lang.uppercased(), icon: "character.cursor.ibeam", tint: .indigo)
                GlassyButton("Currency", subtitle: user.currency.rawValue, icon: user.currency.sfSymbol, tint: .yellow)
            }
            
            GlassyActionCard("Request account removal", icon: "person.crop.circle.badge.minus", tint: .red, role: .destructive) {
                requestAccountRemoval()
            }
            
            GlassyActionCard("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive) {
                logout()
            }
        }
        .alert("Too many open tickets", isPresented: $ticketVM.alertTooManyTickets) {
            Button("Okay") {}
        } message: {
            Text("You already have 2 open tickets")
        }
        .sheet($ticketVM.showCreateSheet) {
            NavigationStack {
                CreateTicketSheet(
                    navigationTitle: "Request account removal",
                    title: "Request account removal",
                    isTitleEditable: false,
                    showsTitleSection: false,
                    isMessageRequired: false,
                    areAttachmentsOptional: true
                )
                .environment(ticketVM)
            }
        }
    }
    
    private func requestAccountRemoval() {
        Task {
            await ticketVM.fetchTickets()
            ticketVM.createNewTicket()
        }
    }
    
    private func logout() {
        dismiss()
        
        Task {
            try? await Task.sleep(for: .seconds(0.5))
            let token = accessToken()
            
#if os(iOS)
            if let token {
                let _ = await billingLogoutAPI(accessToken: token)
            }
#endif
#if os(iOS)
            await PushTokenService.invalidateIfPossible()
#endif
            if !deleteBillingSessionToken() {
                Logger().error("Error logging out")
            }
            
            store.accessToken = nil
            
            withAnimation {
                store.updateAccessToken()
            }
        }
    }
}

#Preview {
    AccountSettingsSection(.preview)
        .darkSchemePreferred()
        .environment(BillingSettingsVM())
        .environment(DashboardVM())
}
