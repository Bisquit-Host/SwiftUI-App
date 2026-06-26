import SwiftUI
import Calagopus

struct PanelCodexChatMessageRow: View {
    let message: PanelCodexChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 40)
            }
            
            Text(message.content)
                .textSelection(.enabled)
                .padding()
                .background {
                    if message.isUser {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.blue.opacity(0.25))
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.regularMaterial)
                    }
                }
            
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
