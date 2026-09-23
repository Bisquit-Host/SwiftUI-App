import ScrechKit
import Calagopus

struct AgentPendingApprovalView: View {
    @Environment(AgentChatVM.self) private var vm
    
    let approval: AgentPendingApproval
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(approval.toolName, systemImage: "checkmark.shield")
                .headline()
            
            if !approval.summary.isEmpty {
                Text(approval.summary)
                    .secondary()
            }
            
            HStack {
                AsyncButton("Reject", systemImage: "xmark", role: .destructive) {
                    await vm.resolveApproval(approved: false)
                }
                .secondary()
                
                AsyncButton("Approve", systemImage: "checkmark") {
                    await vm.resolveApproval(approved: true)
                }
                .buttonStyle(.borderedProminent)
            }
            .disabled(vm.isResolvingApproval)
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
    }
}

#Preview {
    AgentPendingApprovalView(approval: AgentPendingApproval(.object(["toolName": .string("write"), "summary": .string("Update server files")]))!)
        .padding()
        .darkSchemePreferred()
        .environment(AgentChatVM())
}
