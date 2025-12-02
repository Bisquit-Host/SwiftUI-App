import SwiftUI

struct BillingDashboardHostingLinks: View {
    var body: some View {
        BillingSectionCard("Hosting") {
            VStack(spacing: 12) {
                BillingHostingNavRow(.game, tint: .indigo)
                BillingHostingNavRow(.cloud, tint: .orange)
                BillingHostingNavRow(.bot, tint: .green)
            }
        }
    }
}
