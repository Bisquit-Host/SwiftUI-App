import SwiftUI

struct SecuritySettingsPasskeysButton: View {
    @State private var vm = PasskeyListVM()
    
    var body: some View {
        GlassyNavLink("Passkeys", subtitle: "Passwordless sign in", icon: "person.badge.key.fill", tint: vm.passkeys.isEmpty ? .red : .green) {
            PasskeyList()
                .environment(vm)
        }
        .task {
            await vm.fetchPasskeys()
        }
    }
}

//#Preview {
//    SecuritySettingsPasskeysButton()
//        .darkSchemePreferred()
//}
