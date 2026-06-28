import SwiftUI

struct DashboardAvailableServices: View {
    var body: some View {
        BillingSectionCard(showsBackground: false) {
            Text("Available services")
                .headline()
            
            DashboardCard(.cloud, tint: .orange)
            DashboardCard(.game, tint: .indigo)
            DashboardCard(.bot, tint: .green)
        }
    }
}
