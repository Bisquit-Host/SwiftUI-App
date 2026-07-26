import SwiftUI

struct DashboardSupportSection: View {
    @State private var ticketVM = TicketListVM()
    
    var body: some View {
        BillingSectionCard("Help", showsBackground: false) {
            NavigationLink {
                TicketList()
                    .environment(ticketVM)
            } label: {
                DashboardCardLabel("Support", description: "Tickets", icon: "lifepreserver", tint: .red)
                    .padding(10)
                    .dashboardButtonCardBackground()
            }
            .buttonStyle(.plain)
            
            NavigationLink {
                SupportWikiView()
            } label: {
                DashboardCardLabel("Wiki", description: "How to...?", icon: "books.vertical", tint: .orange)
                    .padding(10)
                    .dashboardButtonCardBackground()
            }
            .buttonStyle(.plain)
        }
    }
}
