import SwiftUI

struct PanelCodexChatButton: View {
    @Binding private var isPresented: Bool

    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }

    var body: some View {
        Button("Codex", systemImage: "siri") {
            isPresented = true
        }
        .labelStyle(.iconOnly)
        .font(.title2)
        .frame(width: 56, height: 56)
        .background(.regularMaterial, in: .circle)
        .overlay {
            Circle()
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
        .buttonStyle(.plain)
        .padding()
    }
}

#Preview {
    @Previewable @State var isPresented = false

    PanelCodexChatButton(isPresented: $isPresented)
        .darkSchemePreferred()
}
