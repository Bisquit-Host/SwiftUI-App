import SwiftUI

struct PanelCodexChatInputBar: View {
    @Environment(PanelCodexChatVM.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        HStack(alignment: .bottom) {
            TextField("Ask Codex", text: $vm.message, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .disabled(vm.isSending)
                .onSubmit(send)

            Button("Send", systemImage: "paperplane", action: send)
                .buttonStyle(.borderedProminent)
                .disabled(vm.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func send() {
        Task {
            await vm.sendMessage()
        }
    }
}

#Preview {
    PanelCodexChatInputBar()
        .darkSchemePreferred()
        .environment(PanelCodexChatVM())
}
