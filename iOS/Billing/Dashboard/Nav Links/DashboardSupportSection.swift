import SwiftUI

struct DashboardSupportSection: View {
    @Environment(TicketListVM.self) private var vm
    
    var body: some View {
        BillingSectionCard("Help", showsBackground: false) {
            NavigationLink {
                TicketList()
                    .environment(vm)
            } label: {
                DashboardCardLabel("Support", description: "Tickets", icon: "lifepreserver", tint: .red)
                    .padding(10)
                    .dashboardButtonCardBackground()
            }
            .buttonStyle(.plain)
            
            NavigationLink {
                TicketList()
                    .environment(vm)
            } label: {
                DashboardCardLabel("Wiki", description: "How to...?", icon: "books.vertical", tint: .orange)
                    .padding(10)
                    .dashboardButtonCardBackground()
            }
            .buttonStyle(.plain)
        }
    }
}
