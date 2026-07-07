import SwiftUI

struct AccoutSettingsLogoutButton: View {
    @Environment(NavState.self) private var nav
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        GlassyActionCard("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive, action: logout)
    }
    
    private func logout() {
        nav.clear()
        
#if os(iOS) && BISQUIT_HOST_APP
        deletePanelSession()
        
        if accessToken() != nil {
            store.homeSelectedTab = .billing
        }
#endif
        
        dismiss()
    }
}

#Preview {
    AccoutSettingsLogoutButton()
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(ValueStore())
}
