import ScrechKit

struct SecuritySettings2FAButton: View {
    @State private var twoFAVM = Billing2FAVM()
    @Environment(DashboardVM.self) private var dashboardVM
    
    private let `2FAEnabled`: Bool
    
    init(_ `2FAEnabled`: Bool) {
        self.`2FAEnabled` = `2FAEnabled`
    }
    
    @State private var show2FASheet = false
    @State private var alertDisable2FA = false
    @State private var isProcessing = false
    @State private var disableCode = ""
    
    var body: some View {
        BillingSecurityRow("2FA", icon: "shield.fill", enabled: `2FAEnabled`, enabledText: "Disable", disabledText: "Connect") {
            disableCode = ""
            alertDisable2FA = true
        } onDisabledTap: {
            show2FASheet = true
        }
        .alert("Disable 2FA?", isPresented: $alertDisable2FA) {
            TextField("Code", text: $disableCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .limitInputLength($disableCode, length: 6)
            
            AsyncButton("Disable", role: .destructive, action: disable2FA)
                .disabled(isProcessing || disableCode.count < 6)
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the code from your authenticator app to remove extra protection for your account")
        }
        .sheet($show2FASheet) {
            NavigationStack {
                Billing2FASetup()
                    .environment(twoFAVM)
            }
        }
    }
    
    private func disable2FA() async {
        guard !isProcessing else { return }
        isProcessing = true
        
        let success = await twoFAVM.disable(code: disableCode)
        isProcessing = false
        
        if success {
            disableCode = ""
            await dashboardVM.fetchUserInfo()
        } else {
            alertDisable2FA = true
        }
    }
}

//#Preview {
//    SecuritySettings2FAButton()
//        .darkSchemePreferred()
//}
