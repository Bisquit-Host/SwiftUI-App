import SwiftUI

struct DashboardViewHostingLinks: View {
    var body: some View {
        BillingSectionCard(showsBackground: false) {
            Text("Hosting")
                .headline()
            
            VStack(spacing: 12) {
                BillingHostingNavRow(.cloud, tint: .orange)
                BillingHostingNavRow(.game, tint: .indigo)
                BillingHostingNavRow(.bot, tint: .green)
            }
        }
    }
}
