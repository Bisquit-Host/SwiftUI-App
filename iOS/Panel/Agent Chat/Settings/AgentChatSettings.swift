import ScrechKit

struct AgentChatSettings: View {
    @Environment(AgentChatVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private var preferencesLocked: Bool {
        vm.preferencesLocked
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section("Provider") {
                Picker("Provider", selection: $vm.provider) {
                    ForEach(vm.providerOptions, id: \.self) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(preferencesLocked)
            }
            
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
            
            AgentChatPermissionSettings()
            
            if vm.provider == .codex {
                Section("ChatGPT Subscription") {
                    AsyncButton(
                        "Log out",
                        systemImage: "rectangle.portrait.and.arrow.right",
                        role: .destructive
                    ) {
                        await vm.logoutCodexIntegration()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: vm.provider) {
            updatePreferences()
        }
        .onChange(of: vm.webSearchEnabled) {
            updatePreferences()
        }
        .onChange(of: vm.fullAccess) {
            updatePreferences()
        }
        .onChange(of: vm.approvalPolicies) {
            updatePreferences()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton()
            }
        }
    }
    
    private func updatePreferences() {
        Task {
            await vm.updatePreferences()
        }
    }
}

#Preview {
    NavigationStack {
        AgentChatSettings()
    }
    .darkSchemePreferred()
    .environment(AgentChatVM())
}
