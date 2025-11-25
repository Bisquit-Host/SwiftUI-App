import ScrechKit

struct Enable2FAView: View {
    @Environment(AccountVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var code = ""
    @State private var sheetQrCode = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                introSection
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Setup options")
                        .footnote(.semibold)
                        .secondary()
                    
                    TwoFAActionGrid(
                        qrCodeUrl: vm.qrCodeUrl,
                        onShowQr: { sheetQrCode = true }
                    )
                }
                
                codeInput
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .sheet($sheetQrCode) {
            QRCodeView(vm.qrCodeUrl)
                .presentationDetents([.medium])
        }
        .toolbar {
            ToolbarSpacer(.flexible, placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
        }
    }
    
    private var introSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lock.shield")
                    .title(.semibold)
                    .frame(46)
                    .foregroundStyle(.white)
                    .background(.blue.gradient, in: .rect(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable 2FA")
                        .title2(.semibold)
                    
                    Text("Use your authenticator app to scan the code or open the setup link, then confirm the 6-digit code below")
                        .secondary()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            
            instructionsCard
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
    
    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How it works")
                .footnote(.semibold)
                .secondary()
            
            VStack(alignment: .leading, spacing: 10) {
                instructionRow("Scan or open the setup link", systemImage: "qrcode")
                instructionRow("Your app will generate a 6-digit code", systemImage: "keyboard")
                instructionRow("Enter the code here to activate", systemImage: "checkmark.seal")
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
        .padding([.bottom, .horizontal])
    }
    
    private func instructionRow(_ text: LocalizedStringKey, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .bold()
                .frame(30)
                .foregroundStyle(.white)
                .background(.blue.gradient.opacity(0.9), in: .rect(cornerRadius: 8))
            
            Text(text)
                .secondary()
        }
    }
    
    private var codeInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter the 6-digit code")
                .semibold()
            
            TextField("123 456", text: $code)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
                .monospaced()
                .padding(.vertical, 14)
                .padding(.horizontal)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 14))
            
            Button {
                verifyCode()
            } label: {
                Text("Verify & Enable")
                    .semibold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.glassProminent)
            .tint(.green)
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 18))
    }
    
    private func verifyCode() {
        Task {
            await vm.enable2Fa(code) {
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
