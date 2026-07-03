import SwiftUI
import Calagopus

struct PanelCodexChatMessageRow: View {
    let message: PanelCodexChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 40)

                Text(message.markdownContent)
                    .textSelection(.enabled)
                    .padding(12)
                    .glassEffect(.regular.tint(.blue.opacity(0.25)), in: .rect(cornerRadius: 14))
            } else {
                Text(message.markdownContent)
                    .textSelection(.enabled)

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
