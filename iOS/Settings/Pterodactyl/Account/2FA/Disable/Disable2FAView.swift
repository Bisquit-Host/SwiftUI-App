import ScrechKit

struct Disable2FAView: View {
    @Environment(AccountVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Disable2FASheet()
                
                DisablePasswordCard(password: $password) {
                    disable2FA()
                }
            }
            .navigationTitle("Disable 2FA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
            }
        }
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
