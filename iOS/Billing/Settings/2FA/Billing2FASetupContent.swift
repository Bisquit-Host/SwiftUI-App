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
            if let qr = generateQRCode(setup.url) {
                Image(uiImage: qr)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 240)
                    .clipShape(.rect(cornerRadius: 12))
            }
            
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
    
    private func generateQRCode(_ text: String) -> UIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        let data = text.data(using: .utf8)
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let qrImage = qrFilter.outputImage else {
            return nil
        }
        
        let transform = CGAffineTransform(scaleX: 8, y: 8)
        let scaledQRImage = qrImage.transformed(by: transform)
        
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

//#Preview {
//    Billing2FASetupContent()
//        .darkSchemePreferred()
//        .environment(Billing2FAVM())
//}
