import SwiftUI

struct SecuritySettingsPasswordButton: View {
    private let hasPassword: Bool
    
    init(_ hasPassword: Bool) {
        self.hasPassword = hasPassword
    }
    
    @State private var sheetPassword = false
    
    var body: some View {
        BillingSecurityRow("Password", icon: "key.fill", enabled: hasPassword, enabledText: "Change", disabledText: "Set") {
            sheetPassword = true
        } onDisabledTap: {
            sheetPassword = true
        }
        .sheet($sheetPassword) {
            NavigationStack {
                BillingPasswordSheet(hasPassword)
            }
        }
    }
}

//#Preview {
//    SecuritySettingsPasswordButton()
//        .darkSchemePreferred()
//}
