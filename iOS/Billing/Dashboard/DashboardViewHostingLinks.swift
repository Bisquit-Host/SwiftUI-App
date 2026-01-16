import SwiftUI

struct DashboardViewHostingLinks: View {
    var body: some View {
        BillingSectionCard("Hosting") {
            VStack(spacing: 12) {
                BillingHostingNavRow(.cloud, tint: .orange)
                BillingHostingNavRow(.game, tint: .indigo)
                BillingHostingNavRow(.bot, tint: .green)
            }
        }
    }
}
