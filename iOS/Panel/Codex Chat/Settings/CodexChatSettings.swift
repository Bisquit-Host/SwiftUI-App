import ScrechKit

struct CodexChatSettings: View {
    @Environment(CodexChatVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                Toggle(isOn: $vm.webSearchEnabled) {
                    Label("Web search", systemImage: "globe")
                }
                .disabled(preferencesLocked)
                
                Toggle(isOn: $vm.fullAccess) {
                    Label("Full access", systemImage: "exclamationmark.shield")
                }
                .disabled(preferencesLocked)
            }
            
            Section("ChatGPT Subscription") {
                Button(
                    "Log out",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    role: .destructive,
                    action: logout
                )
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: vm.webSearchEnabled) {
            updatePreferences()
        }
        .onChange(of: vm.fullAccess) {
            updatePreferences()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton()
            }
        }
    }
    
    private var preferencesLocked: Bool {
        vm.isUpdatingPreferences || vm.isSending || vm.shouldPoll
    }
    
    private func updatePreferences() {
        Task {
            await vm.updatePreferences()
        }
    }
    
    private func logout() {
        Task {
            await vm.logoutCodexIntegration()
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        CodexChatSettings()
    }
    .darkSchemePreferred()
    .environment(CodexChatVM())
}
