import SwiftUI

struct Disable2FaView: View {
    @Environment(AccountVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Enter your password")
                .headline()
            
            TextField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
            
            Button("Disable 2FA", role: .destructive) {
                disable2FA()
            }
            .semibold()
            .buttonStyle(.glassProminent)
            .tint(.red)
        }
        .padding(.horizontal)
        .multilineTextAlignment(.center)
        .presentationDetents([.medium])
    }
    
    private func disable2FA() {
        Task {
            await vm.disable2Fa(password) {
                dismiss()
            }
        }
    }
}

#Preview {
    Text("")
        .sheet {
            Disable2FaView()
                .environment(AccountVM())
        }
        .darkSchemePreferred()
}
