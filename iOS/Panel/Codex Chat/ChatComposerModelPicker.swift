import ScrechKit

@available(iOS 26, macOS 26, *)
struct ChatComposerModelPicker: View {
    @Binding private var selectedModel: String
    @Binding private var selectedReasoningEffort: String
    private let modelOptions: [String]
    private let reasoningEffortOptions: [String]
    private let preferencesLocked: Bool
    private let preferencesChanged: () -> Void

    init(
        selectedModel: Binding<String>,
        selectedReasoningEffort: Binding<String>,
        modelOptions: [String],
        reasoningEffortOptions: [String],
        preferencesLocked: Bool,
        preferencesChanged: @escaping () -> Void
    ) {
        _selectedModel = selectedModel
        _selectedReasoningEffort = selectedReasoningEffort
        self.modelOptions = modelOptions
        self.reasoningEffortOptions = reasoningEffortOptions
        self.preferencesLocked = preferencesLocked
        self.preferencesChanged = preferencesChanged
    }

    var body: some View {
        Menu {
            Section {
                Menu {
                    Picker("Model", selection: $selectedModel) {
                        ForEach(modelOptions.reversed(), id: \.self) {
                            Text($0.replacing("gpt-", with: ""))
                                .tag($0)
                        }
                    }
                } label: {
                    Text("Model")
                    Text(selectedModel.replacing("gpt-", with: ""))
                }
            }

            Section {
                Picker("Reasoning", selection: $selectedReasoningEffort) {
                    ForEach(reasoningEffortOptions.reversed(), id: \.self) {
                        Text(reasoningEffortTitle($0))
                            .tag($0)
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedModel.replacing("gpt-", with: ""))

                Text(reasoningEffortTitle(selectedReasoningEffort))
                    .secondary()
            }
            .footnote()
            .tint(.primary)
        }
        .disabled(preferencesLocked)
        .onChange(of: selectedModel) {
            preferencesChanged()
        }
        .onChange(of: selectedReasoningEffort) {
            preferencesChanged()
        }
    }

    private func reasoningEffortTitle(_ effort: String) -> String {
        switch effort {
        case "low": "Light"
        case "medium": "Medium"
        case "high": "High"
        case "xhigh", "extra_high": "Extra High"

        default:
            effort
                .split(separator: "_")
                .map(\.capitalized)
                .joined(separator: " ")
        }
    }
}

#Preview {
    ChatComposerModelPicker(
        selectedModel: .constant("gpt-5"),
        selectedReasoningEffort: .constant("medium"),
        modelOptions: ["gpt-5"],
        reasoningEffortOptions: ["low", "medium", "high", "xhigh"],
        preferencesLocked: false,
        preferencesChanged: {}
    )
        .darkSchemePreferred()
}
