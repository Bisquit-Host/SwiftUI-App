import SwiftUI

struct HCaptchaSheet: View {
    @State private var vm = HCaptchaVM()
    @StateObject private var captchaHost = CaptchaHost()
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var hcaptchaToken: String
    
    init(_ hcaptchaToken: Binding<String>) {
        _hcaptchaToken = hcaptchaToken
    }
    
    var body: some View {
        UIViewWrapperView(host: captchaHost)
            .ignoresSafeArea()
            .task {
                vm.configure(captchaHost.view)
                vm.validate(captchaHost.view)
            }
            .onChange(of: vm.token) { _, newToken in
                if let newToken {
                    hcaptchaToken = newToken
                    dismiss()
                } else {
                    print("Invalid token")
                }
            }
    }
}
