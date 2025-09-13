import SwiftUI

struct DashboardViewHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Server name")
                .largeTitle(.bold)
            
            Text("Server description")
                .title3()
                .secondary()
        }
    }
}

#Preview {
    DashboardViewHeader()
}
