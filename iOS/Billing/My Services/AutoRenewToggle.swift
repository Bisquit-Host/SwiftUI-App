import ScrechKit

struct AutoRenewToggle: View {
    @Binding var autorenewToggle: Bool
    @Binding var syncedAutorenew: Bool
    let autorenew: Bool
    let isPerformingAction: Bool
    let action: (Bool) async -> Void
    
    @State private var alertRenewInfo = false
    
    var body: some View {
        Toggle(isOn: $autorenewToggle) {
            HStack(spacing: 5) {
                Text("Auto-renew")
                
                SFButton("questionmark.circle.fill") {
                    alertRenewInfo = true
                }
                .footnote()
                .secondary()
            }
        }
        .toggleStyle(.switch)
        .disabled(isPerformingAction)
        .subheadline()
        .task(id: autorenew) {
            syncedAutorenew = autorenew
            autorenewToggle = autorenew
        }
        .onChange(of: autorenewToggle) { _, newValue in
            guard newValue != syncedAutorenew else { return }
            
            Task {
                await action(newValue)
                
                let actualValue = autorenew
                syncedAutorenew = actualValue
                autorenewToggle = actualValue
            }
        }
        .alert("Auto-renew", isPresented: $alertRenewInfo) {
            
        } message: {
            Text("Automatically charges the one-month amount from your billing balance, not from your bank account")
        }
    }
}

//#Preview {
//    AutoRenewToggle()
//}
