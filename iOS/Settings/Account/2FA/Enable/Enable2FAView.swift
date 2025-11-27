import ScrechKit

struct Enable2FAView: View {
    @Environment(AccountVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var code = ""
    @State private var password = ""
    @State private var sheetQrCode = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                EnableIntroCard()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Setup options")
                        .footnote(.semibold)
                        .secondary()
                    
                    TwoFAActionGrid(vm.qrCodeURL) {
                        sheetQrCode = true
                    }
                }
                
                EnableCodeInputCard(code: $code, password: $password) {
                    verifyCode()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .sheet($sheetQrCode) {
            QRCodeView(vm.qrCodeURL)
                .presentationDetents([.medium])
        }
        .toolbar {
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
        }
    }
    
    private func verifyCode() {
        Task {
            await vm.enable2Fa(code, password: password) {
                dismiss()
            }
        }
    }
}

#Preview {
    Enable2FAView()
        .darkSchemePreferred()
        .environment(AccountVM())
}
