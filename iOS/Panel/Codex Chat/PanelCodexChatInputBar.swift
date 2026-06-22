import SwiftUI

struct PanelCodexChatInputBar: View {
    @Environment(PanelCodexChatVM.self) private var vm
    @FocusState private var isFocused: Bool

    var body: some View {
        @Bindable var vm = vm

        ChatComposer(
            prompt: $vm.message,
            isResponding: $vm.isSending,
            isFocused: $isFocused,
            sendPrompt: send
        )
        .task {
            isFocused = true
        }
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
