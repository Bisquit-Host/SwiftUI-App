import SwiftUI

struct HCaptchaSheet: View {
    @StateObject private var vm = HCaptchaVM()
    @State private var showsError = false
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var hcaptchaToken: String
    
    init(_ hcaptchaToken: Binding<String>) {
        _hcaptchaToken = hcaptchaToken
    }
    
    var body: some View {
        ZStack {
            HCaptchaWebView(vm: vm)
            
            if vm.isLoading {
                ProgressView("Loading captcha...")
                    .padding()
                    .glassBackgroundEffect()
            }
        }
        .frame(minWidth: 520, minHeight: 420)
        .onChange(of: vm.token) { _, newToken in
            guard let newToken else { return }
            hcaptchaToken = newToken
            dismiss()
        }
        .onChange(of: vm.errorMessage) { _, newValue in
            showsError = newValue != nil
        }
        .alert("Captcha failed", isPresented: $showsError) {
            Button("OK") {
                vm.errorMessage = nil
            }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
