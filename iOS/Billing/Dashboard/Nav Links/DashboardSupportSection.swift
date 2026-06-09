import SwiftUI

struct DashboardSupportSection: View {
    var body: some View {
        BillingSectionCard("Help", showsBackground: false) {
            VStack(spacing: 12) {
                NavigationLink {
                    SupportView()
                } label: {
                    DashboardCardLabel("Support", description: "Tickets", icon: "lifepreserver", tint: .red)
                }
                .buttonStyle(.plain)
                .padding(10)
                .containerShape(.rect(cornerRadius: 12))
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                
                NavigationLink {
                    SupportView()
                } label: {
                    DashboardCardLabel("Wiki", description: "How to...?", icon: "books.vertical", tint: .orange)
                }
                .buttonStyle(.plain)
                .padding(10)
                .containerShape(.rect(cornerRadius: 12))
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
            }
        }
    }
}
