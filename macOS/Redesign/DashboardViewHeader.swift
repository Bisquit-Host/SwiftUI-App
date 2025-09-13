import SwiftUI

struct DashboardViewHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome Back, John Connor! 👋")
                .title(.bold)
            
            Text("4 Tasks Due Today, 2 Overdue Tasks, 8 Upcoming Deadlines (This Week)")
                .secondary()
        }
    }
}

#Preview {
    DashboardViewHeader()
}
