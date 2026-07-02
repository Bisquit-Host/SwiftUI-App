import SwiftUI

struct PanelCodexChatThinkingView: View {
    static let scrollID = "panel-codex-thinking"
    
    var body: some View {
        HStack {
            Text("Thinking")
                .footnote()
                .secondary()
            
            ProgressView()
                .controlSize(.small)
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PanelCodexChatThinkingView()
        .padding()
        .darkSchemePreferred()
}
