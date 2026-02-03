import SwiftUI

struct DashboardViewHostingLinks: View {
    var body: some View {
        BillingSectionCard(showsBackground: false) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Hosting")
                    .headline()
                
                Text("Browse plans by category")
                    .footnote()
                    .secondary()
            }
            
            VStack(spacing: 12) {
                BillingHostingNavRow(.cloud, tint: .orange)
                BillingHostingNavRow(.game, tint: .indigo)
                BillingHostingNavRow(.bot, tint: .green)
            }
        }
    }
}
