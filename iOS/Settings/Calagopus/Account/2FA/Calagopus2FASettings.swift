import ScrechKit

struct Calagopus2FASettings: View {
    @Environment(AccountVM.self) private var vm
    
    @State private var alertDisable2Fa = false
    @State private var sheetEnable2Fa = false
    
    var body: some View {
        if let twoFaEnabled = vm.twoFaEnabled {
            AuthSettingsAppCard("2FA", icon: "shield.fill", enabled: twoFaEnabled) {
                sheetEnable2Fa = true
            } onDisconnect: {
                alertDisable2Fa = true
            }
            .disabled(vm.isDisabling2FA)
            .modifier(DisableTwoFAAlert(isPresented: $alertDisable2Fa) { password in
                Task {
                    await vm.disable2Fa(password) {}
                }
            })
            .sheet($sheetEnable2Fa) {
                NavigationStack {
                    Enable2FAView()
                }
            }
        }
    }
}

#Preview {
    Calagopus2FASettings()
        .darkSchemePreferred()
        .environment(AccountVM())
}
