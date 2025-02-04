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
                vm.disable2Fa(code) {
                    dismiss()
                }
            }
        }
        .multilineTextAlignment(.center)
        .presentationDetents([.medium])
    }
}

#Preview {
    Disable2FaView()
        .environment(AccountVM())
}
