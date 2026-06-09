import SwiftUI

struct DashboardSupportSection: View {
    var body: some View {
        BillingSectionCard("Help", showsBackground: false) {
            VStack(spacing: 12) {
                DashboardNavLink("Support", subtitle: "Tickets", systemImage: "lifepreserver", tint: .red) {
                    SupportView()
                }
                
                DashboardNavLink("Wiki", subtitle: "How to...?", systemImage: "books.vertical", tint: .orange) {
                    SupportWikiView()
                }
            }
        }
    }
}
