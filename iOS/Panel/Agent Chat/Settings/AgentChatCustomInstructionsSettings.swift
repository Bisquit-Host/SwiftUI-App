import ScrechKit

struct AgentChatCustomInstructionsSettings: View {
    @Environment(AgentChatVM.self) private var vm
    @FocusState private var isFocused: Bool
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            TextField(
                "Example: Always back up a server before changing plugins",
                text: $vm.customInstructions,
                axis: .vertical
            )
            .lineLimit(3...8)
            .focused($isFocused)
            .disabled(vm.preferencesLocked)
            .onChange(of: isFocused) { wasFocused, focused in
                guard wasFocused, !focused else { return }
                
                save()
            }
            .onDisappear(perform: save)
        } header: {
            Text("Custom Instructions")
        } footer: {
            Text("The agent follows these in every chat")
        }
    }
    
    private func save() {
        guard vm.hasUnsavedCustomInstructions else { return }
        
        Task {
            await vm.updatePreferences()
        }
    }
}

#Preview {
    List {
        AgentChatCustomInstructionsSettings()
    }
    .darkSchemePreferred()
    .environment(AgentChatVM())
}
