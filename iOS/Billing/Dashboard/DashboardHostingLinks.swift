import SwiftUI

struct DashboardHostingLinks: View {
    var body: some View {
        BillingSectionCard(showsBackground: false) {
            Text("Available services")
                .headline()
            
            VStack(spacing: 12) {
                DashboardCard(.cloud, tint: .orange)
                DashboardCard(.game, tint: .indigo)
                DashboardCard(.bot, tint: .green)
            }
        }
    }
}
