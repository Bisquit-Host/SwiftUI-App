import SwiftUI

struct SecuritySettings2FAButton: View {
    @State private var `2FAVM` = Billing2FAVM()
    @Environment(DashboardVM.self) private var dashboardVM
    
    private let `2FAEnabled`: Bool
    
    init(_ `2FAEnabled`: Bool) {
        self.`2FAEnabled` = `2FAEnabled`
    }
    
    @State private var show2FASheet = false
    @State private var alertDisable2FA = false
    @State private var isProcessing = false
    
    var body: some View {
        BillingSecurityRow("2FA", icon: "shield.fill", enabled: `2FAEnabled`, enabledText: "Disable", disabledText: "Connect") {
            alertDisable2FA = true
        } onDisabledTap: {
            show2FASheet = true
        }
        .alert("Disable 2FA?", isPresented: $alertDisable2FA) {
            Button("Disable", role: .destructive, action: disable2FA)
                .disabled(isProcessing)
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will remove extra protection for your account")
        }
        .sheet($show2FASheet) {
            NavigationStack {
                Billing2FASetup()
                    .environment(`2FAVM`)
            }
        }
    }
    
    private func disable2FA() {
        guard !isProcessing else { return }
        isProcessing = true
        
        Task {
            let success = await `2FAVM`.disable()
            isProcessing = false
            
            if success {
                await dashboardVM.fetchUserInfo()
            } else {
                alertDisable2FA = true
            }
        }
    }
}

//#Preview {
//    SecuritySettings2FAButton()
//        .darkSchemePreferred()
//}
