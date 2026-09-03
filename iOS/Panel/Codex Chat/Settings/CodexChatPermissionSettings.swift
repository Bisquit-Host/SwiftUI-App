import ScrechKit

struct CodexChatPermissionSettings: View {
    @Environment(CodexChatVM.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        Section {
            Text(vm.fullAccess ? "Full access is on, so approval prompts are bypassed. You can still edit these rules for later" : "Toggle which actions pause for approval before they run")
                .foregroundStyle(.secondary)

            ForEach($vm.approvalPolicies) { $policy in
                Toggle(isOn: $policy.enabled) {
                    VStack(alignment: .leading) {
                        Text(policy.label)
                        Text(policy.description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(vm.preferencesLocked)
            }
        } header: {
            Text("Approval Rules")
        }
    }
}

#Preview {
    List {
        CodexChatPermissionSettings()
    }
    .darkSchemePreferred()
    .environment(CodexChatVM())
}
