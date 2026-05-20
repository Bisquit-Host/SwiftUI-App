import ScrechKit

struct Disable2FaView: View {
    @Environment(AccountVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var password = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                DisableIntroCard()
                
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
            Disable2FaView()
                .environment(AccountVM())
        }
        .darkSchemePreferred()
}
