import SwiftUI

struct Disable2FaView: View {
    @Environment(AccountVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var code = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Enter the 6-digit code from your authenticator app")
                .headline()
            
            TextField("Password", text: $code)
                .padding(.horizontal)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
            
            Button("Disable 2FA") {
                disable2FA()
            }
        }
        .multilineTextAlignment(.center)
        .presentationDetents([.medium])
    }
    
    private func disable2FA() {
        Task {
            await vm.disable2Fa(code) {
                dismiss()
            }
        }
    }
}

#Preview {
    Disable2FaView()
        .environment(AccountVM())
}
