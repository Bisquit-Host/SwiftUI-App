import SwiftUI

struct CodexChatThinkingView: View {
    static let scrollID = "codex-thinking"
    
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
    CodexChatThinkingView()
        .padding()
        .darkSchemePreferred()
}
