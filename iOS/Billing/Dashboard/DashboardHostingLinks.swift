import SwiftUI

struct DashboardHostingLinks: View {
    var body: some View {
        BillingSectionCard(showsBackground: false) {
            Text("Available services")
                .headline()
            
            VStack(spacing: 12) {
                BillingHostingNavRow(.cloud, tint: .orange)
                BillingHostingNavRow(.game, tint: .indigo)
                BillingHostingNavRow(.bot, tint: .green)
            }
        }
    }
}
