import SwiftUI

struct HomeTabView: View {
    var body: some View {
        Dashboard()
    }
}

#Preview {
    NavigationStack {
        HomeTabView()
    }
    .environmentObject(ValueStore())
}
