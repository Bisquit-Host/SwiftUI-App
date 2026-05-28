import SwiftUI

struct LoginAppleButton: View {
    @Environment(LoginVM.self) private var vm
    
    let handleAuthResponse: (BillingSessionAuthResponse) -> Void
    
    var body: some View {
        Button(action: loginWithApple) {
            if vm.isAppleLoading {
                HStack {
                    ProgressView()
                    Text("Signing in with Apple...")
                }
            } else {
                Label("Sign in with Apple", systemImage: "apple.logo")
                    .labelIconToTitleSpacing(10)
                    .semibold()
                    .rounded()
            }
        }
        .disabled(vm.isAppleLoading)
        .foregroundStyle(.foreground)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
#if !os(visionOS)
        .glassEffect()
#endif
    }
    
    private func loginWithApple() {
        Task {
            guard let response = await vm.loginWithApple() else {
                return
            }
            
            handleAuthResponse(response)
        }
    }
}

#Preview {
    LoginAppleButton { _ in }
        .environment(LoginVM())
        .padding()
}
