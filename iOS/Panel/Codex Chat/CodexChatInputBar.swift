import SwiftUI

#warning("Remove???")
struct CodexChatInputBar: View {
    @Environment(CodexChatVM.self) private var vm
    @FocusState private var isFocused: Bool
    
    var body: some View {
        @Bindable var vm = vm
        
        ChatComposer(
            prompt: $vm.message,
            isResponding: vm.isSending || vm.shouldPoll,
            selectedModel: $vm.codexModel,
            selectedReasoningEffort: $vm.codexReasoningEffort,
            fastMode: $vm.fastMode,
            fastModeOptions: vm.fastModeOptions,
            webSearchEnabled: $vm.webSearchEnabled,
            fullAccess: $vm.fullAccess,
            modelOptions: vm.codexModelOptions,
            reasoningEffortOptions: vm.codexReasoningEffortOptions,
            isFocused: $isFocused,
            preferencesLocked: vm.isUpdatingPreferences || vm.isSending || vm.shouldPoll,
            sendPrompt: send,
            preferencesChanged: updatePreferences,
            logout: logoutCodexIntegration,
            stopAction: stop
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
    
    private func stop() {
        Task {
            await vm.stop()
        }
    }
    
    private func logoutCodexIntegration() {
        Task {
            await vm.logoutCodexIntegration()
        }
    }
}

#Preview {
    CodexChatInputBar()
        .darkSchemePreferred()
        .environment(CodexChatVM())
}
