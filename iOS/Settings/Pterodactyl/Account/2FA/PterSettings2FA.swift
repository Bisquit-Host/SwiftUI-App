import ScrechKit

struct PterSettings2FA: View {
    @Environment(AccountVM.self) private var vm
    
    @State private var sheetDisable2Fa = false
    @State private var sheetEnable2Fa = false
    
    var body: some View {
        if let twoFaEnabled = vm.twoFaEnabled {
            AuthSettingsAppCard("2FA", icon: "shield.fill", enabled: twoFaEnabled) {
                sheetEnable2Fa = true
            } onDisconnect: {
                sheetDisable2Fa = true
            }
            .sheet($sheetDisable2Fa) {
                Disable2FAView()
            }
            .sheet($sheetEnable2Fa) {
                NavigationStack {
                    Enable2FAView()
                }
            }
        }
    }
}

#Preview {
    PterSettings2FA()
        .darkSchemePreferred()
        .environment(AccountVM())
}
