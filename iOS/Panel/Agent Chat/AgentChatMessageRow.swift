import SwiftUI
import Calagopus

struct AgentChatMessageRow: View {
    let message: AgentChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 40)
                
                VStack(alignment: .trailing) {
                    if !message.images.isEmpty {
                        AgentChatMessageImagesView(images: message.images)
                    }

                    if !message.content.isEmpty {
                        Text(message.markdownContent)
                            .textSelection(.enabled)
                            .padding(12)
#if !os(visionOS)
                            .glassEffect(.regular.tint(.blue.opacity(0.25)), in: .rect(cornerRadius: 14))
#endif
                    }
                }
            } else {
                Text(message.markdownContent)
                    .textSelection(.enabled)
                
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    AgentChatMessageRow(message: AgentChatMessage(.object(["id": .string("1"), "role": .string("assistant"), "content": .string("Ready")]))!)
        .padding()
        .darkSchemePreferred()
}
