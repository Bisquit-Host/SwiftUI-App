import SwiftUI

struct Billing2FASetupContent: View {
    @Environment(Billing2FAVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let setup: Billing2FASetupResponse
    private let onEnabled: () async -> Void
    
    init(_ setup: Billing2FASetupResponse, onEnabled: @escaping () async -> Void) {
        self.setup = setup
        self.onEnabled = onEnabled
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
                await onEnabled()
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
