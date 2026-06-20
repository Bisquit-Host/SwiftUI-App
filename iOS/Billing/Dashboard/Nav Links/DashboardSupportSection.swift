import SwiftUI

struct DashboardSupportSection: View {
    var body: some View {
        BillingSectionCard("Help", showsBackground: false) {
            VStack(spacing: 12) {
                NavigationLink {
                    SupportView()
                } label: {
                    DashboardCardLabel("Support", description: "Tickets", icon: "lifepreserver", tint: .red)
                        .padding(10)
                        .dashboardButtonCardBackground()
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    SupportView()
                } label: {
                    DashboardCardLabel("Wiki", description: "How to...?", icon: "books.vertical", tint: .orange)
                        .padding(10)
                        .dashboardButtonCardBackground()
                }
                .buttonStyle(.plain)
            }
        }
    }
}
