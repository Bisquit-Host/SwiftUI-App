import ScrechKit
import BisquitoNet

struct BillingTwoFASetupContent: View {
    @Environment(Billing2FAVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    @Environment(\.dismiss) private var dismiss
    
    private let setup: Billing2FASetupResponse
    
    init(_ setup: Billing2FASetupResponse) {
        self.setup = setup
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack(alignment: .leading, spacing: 16) {
            Billing2FASetupContentQRCode(setup)
            
            Button {
                Pasteboard.copy(setup.secret)
            } label: {
                Label("Copy the 2FA secret", systemImage: "document.on.document")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.primary)
            
            ApplePasswords2FAButton(
                serviceName: "bisquit.host",
                accountName: setup.accountName,
                secret: setup.secret
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Code")
                    .footnote(.semibold)
                
                TextField("123456", text: $vm.code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .limitInputLength($vm.code, length: 6)
            }
            
            Spacer()
            
            if vm.isEnabling || vm.isLoading {
                ProgressView()
            } else {
                WideButton("Enable 2FA", action: enableTwoFA)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.code.trimmingCharacters(in: .whitespaces).count < 6 || vm.isEnabling || vm.isLoading)
            }
        }
    }
    
    private func enableTwoFA() {
        Task {
            vm.isLoading = true
            let success = await vm.enable(code: vm.code.trimmingCharacters(in: .whitespaces))
            vm.isLoading = false
            
            if success {
                await dashboardVM.fetchUserInfo()
                dismiss()
            }
        }
    }
}

//#Preview {
//    TwoFASetupContent()
//        .darkSchemePreferred()
//        .environment(Billing2FAVM())
//}
