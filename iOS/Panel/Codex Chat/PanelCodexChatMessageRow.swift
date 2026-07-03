import SwiftUI
import Calagopus

struct PanelCodexChatMessageRow: View {
    let message: PanelCodexChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 40)
            }
            
            Text(message.markdownContent)
                .textSelection(.enabled)
                .padding()
                .glassEffect(.regular.tint(message.isUser ? .blue.opacity(0.25) : .gray.opacity(0.5)), in: .rect(cornerRadius: 14))
            
            if !message.isUser {
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    PanelCodexChatMessageRow(message: PanelCodexChatMessage(.object(["id": .string("1"), "role": .string("assistant"), "content": .string("Ready")]))!)
        .padding()
        .darkSchemePreferred()
}
