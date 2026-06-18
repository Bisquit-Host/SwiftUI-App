import SwiftUI

#if os(iOS)
struct PterodactylHomeView: View {
    var body: some View {
        ServerListParent(showsSettingsToolbarItem: false)
    }
}

#Preview {
    NavigationStack {
        PterodactylHomeView()
    }
    .environment(ServerListVM())
    .environment(NavState())
    .environment(SecurityTasks())
    .environmentObject(ValueStore())
}
#endif
