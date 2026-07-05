import SwiftUI

struct CodexDisconnectedView: View {
    let hasLoadedStatus: Bool
    let userCode: String?
    let connectCodex: () -> Void
    let finishOAuth: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label("Codex is not connected", systemImage: "sparkles")
        } description: {
            Text("Connect Codex to start chatting")
        } actions: {
            if hasLoadedStatus {
                Button("Connect Codex", systemImage: "link", action: connectCodex)
                    .buttonStyle(.borderedProminent)
            }
            
            if let userCode {
                Text(userCode)
                    .monospaced()
                    .textSelection(.enabled)
                
                Button("Finish OAuth", systemImage: "checkmark", action: finishOAuth)
            }
        }
    }
}

#Preview {
    CodexDisconnectedView(
        hasLoadedStatus: true,
        userCode: "ABCD-EFGH",
        connectCodex: {},
        finishOAuth: {}
    )
    .darkSchemePreferred()
}
