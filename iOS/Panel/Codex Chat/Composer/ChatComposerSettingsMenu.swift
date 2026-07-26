import ScrechKit

struct ChatComposerSettingsMenu: View {
    @Environment(CodexChatVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm

        Menu {
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
            
            Section {
                Button(
                    "Log out",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    role: .destructive,
                    action: logout
                )
            }
        } label: {
            Label("Settings", systemImage: "gearshape")
                .labelStyle(.iconOnly)
                .foregroundStyle(.foreground)
                .frame(35)
                .contentShape(.rect)
        }
        .onChange(of: vm.webSearchEnabled) {
            updatePreferences()
        }
        .onChange(of: vm.fullAccess) {
            updatePreferences()
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
        }
    }
}

#Preview {
    ChatComposerSettingsMenu()
        .darkSchemePreferred()
        .environment(CodexChatVM())
}
