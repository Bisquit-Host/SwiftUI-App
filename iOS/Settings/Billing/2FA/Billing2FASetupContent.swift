import SwiftUI
import BisquitoNet

struct Billing2FASetupContent: View {
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Secret")
                    .footnote(.semibold)
                
                CopyableLabel(setup.secret)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Code")
                    .footnote(.semibold)
                
                TextField("123456", text: $vm.code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
            }
            
            Spacer()
            
            Button(action: enableTwoFA) {
                if vm.isEnabling || vm.isLoading {
                    ProgressView()
                } else {
                    Text("Enable 2FA")
                }
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            .disabled(vm.code.trimmingCharacters(in: .whitespaces).count < 6 || vm.isEnabling || vm.isLoading)
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
//    Billing2FASetupContent()
//        .darkSchemePreferred()
//        .environment(Billing2FAVM())
//}
