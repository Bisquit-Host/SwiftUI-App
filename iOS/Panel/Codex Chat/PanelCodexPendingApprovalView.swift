import ScrechKit
import Calagopus

struct PanelCodexPendingApprovalView: View {
    @Environment(PanelCodexChatVM.self) private var vm
    
    let approval: PanelCodexPendingApproval
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(approval.toolName, systemImage: "checkmark.shield")
                .headline()
            
            if !approval.summary.isEmpty {
                Text(approval.summary)
                    .secondary()
            }
            
            HStack {
                Button("Reject", systemImage: "xmark", role: .destructive) {
                    resolve(false)
                }
                .secondary()
                
                Button("Approve", systemImage: "checkmark") {
                    resolve(true)
                }
                .buttonStyle(.borderedProminent)
            }
            .disabled(vm.isResolvingApproval)
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
    }
    
    private func resolve(_ approved: Bool) {
        Task {
            await vm.resolveApproval(approved: approved)
        }
    }
}

#Preview {
    PanelCodexPendingApprovalView(approval: PanelCodexPendingApproval(.object(["toolName": .string("write"), "summary": .string("Update server files")]))!)
        .padding()
        .darkSchemePreferred()
        .environment(PanelCodexChatVM())
}
