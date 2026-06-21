import SwiftUI
import Calagopus

struct AccoutSettingsLogoutButton: View {
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        GlassyActionCard("Log out", icon: "rectangle.portrait.and.arrow.right", tint: .red, role: .destructive, action: logout)
    }
    
    private func logout() {
        nav.clear()
        store.isApiKeyValid = false
        Keychain.delete(key: "selectedApiKey")
    }
}

#Preview {
    AccoutSettingsLogoutButton()
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(ValueStore())
}
