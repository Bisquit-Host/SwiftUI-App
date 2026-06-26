import SwiftUI

#warning("Remove???")
struct PanelCodexChatInputBar: View {
    @Environment(PanelCodexChatVM.self) private var vm
    @FocusState private var isFocused: Bool

    var body: some View {
        @Bindable var vm = vm

        ChatComposer(
            prompt: $vm.message,
            isResponding: $vm.isSending,
            selectedModel: $vm.codexModel,
            selectedReasoningEffort: $vm.codexReasoningEffort,
            modelOptions: vm.codexModelOptions,
            reasoningEffortOptions: vm.codexReasoningEffortOptions,
            isFocused: $isFocused,
            sendPrompt: send,
            preferencesChanged: updatePreferences
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

    private func updatePreferences() {
        Task {
            await vm.updatePreferences()
        }
    }
}

#Preview {
    PanelCodexChatInputBar()
        .darkSchemePreferred()
        .environment(PanelCodexChatVM())
}
