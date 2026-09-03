import ScrechKit

struct ChatComposerBuiltInModelPicker: View {
    @Environment(CodexChatVM.self) private var vm

    var body: some View {
        Menu {
            Section("Model") {
                ForEach(vm.builtInModelOptions) { model in
                    Button {
                        selectModel(model)
                    } label: {
                        if model.id == vm.builtInModel {
                            Label(model.title, systemImage: "checkmark")
                        } else {
                            Text(model.title)
                        }

                        if model.supportsImages {
                            Text("Supports images")
                        }
                    }
                }
            }

            if vm.builtInReasoningEffortOptions.count > 1 {
                Section("Reasoning") {
                    ForEach(vm.builtInReasoningEffortOptions, id: \.self) { effort in
                        if effort == vm.builtInReasoningEffort {
                            Button(reasoningTitle(effort), systemImage: "checkmark") {
                                selectReasoningEffort(effort)
                            }
                        } else {
                            Button(reasoningTitle(effort)) {
                                selectReasoningEffort(effort)
                            }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(vm.builtInModelTitle)
                    .callout(.semibold)

                if !vm.builtInReasoningEffortOptions.isEmpty {
                    Text(reasoningTitle(vm.builtInReasoningEffort))
                        .callout()
                        .secondary()
                }

                Image(systemName: "chevron.down")
                    .caption(.semibold)
                    .secondary()
            }
            .rounded()
        }
        .menuIndicator(.hidden)
        .disabled(vm.preferencesLocked)
    }

    private func selectModel(_ model: CodexChatBuiltInModel) {
        Task {
            await vm.selectBuiltInModel(model)
        }
    }

    private func selectReasoningEffort(_ effort: String) {
        Task {
            await vm.selectBuiltInReasoningEffort(effort)
        }
    }

    private func reasoningTitle(_ effort: String) -> String {
        switch effort {
        case "none": "Off"
        case "light": "Light"
        case "high": "High"
        case "xhigh": "XHigh"
        case "max": "Max"
        default: "Medium"
        }
    }
}

#Preview {
    ChatComposerBuiltInModelPicker()
        .darkSchemePreferred()
        .environment(CodexChatVM())
}
