import SwiftUI

#if os(iOS)
struct CalagopusHomeView: View {
    var body: some View {
        ServerListParent(showsSettingsToolbarItem: false)
    }
}

#Preview {
    NavigationStack {
        CalagopusHomeView()
    }
    .environment(ServerListVM())
    .environment(NavState())
    .environment(SecurityTasks())
    .environmentObject(ValueStore())
}
#endif
