import SwiftUI

struct SupportMessageComposer: View {
    @Binding var text: String
    var isSending: Bool
    var onSend: () async -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type here...", text: $text, axis: .vertical)
                .padding(10)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
            
            Button {
                Task {
                    await onSend()
                }
            } label: {
                Image(systemName: isSending ? "paperplane.fill" : "paperplane")
                    .font(.title3)
                    .padding(5)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial)
    }
}

#Preview {
    @Previewable @State var message = "Preview message"
    
    SupportMessageComposer(text: $message, isSending: false) {}
        .darkSchemePreferred()
}
