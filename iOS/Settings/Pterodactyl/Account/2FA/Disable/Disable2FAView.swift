import ScrechKit

struct Disable2FAView: View {
    @Environment(AccountVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var password = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Disable2FASheet()
                
                DisablePasswordCard(password: $password) {
                    disable2FA()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.never)
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
            Disable2FAView()
                .environment(AccountVM())
        }
        .darkSchemePreferred()
}
