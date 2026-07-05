import ScrechKit

@available(iOS 26, macOS 26, *)
struct ChatComposerModelPicker: View {
    @Binding private var selectedModel: String
    @Binding private var selectedReasoningEffort: String
    @Binding private var fastMode: String
    private let modelOptions: [String]
    private let reasoningEffortOptions: [String]
    private let fastModeOptions: [String]
    private let preferencesLocked: Bool
    private let preferencesChanged: () -> Void
    
    init(
        selectedModel: Binding<String>,
        selectedReasoningEffort: Binding<String>,
        fastMode: Binding<String>,
        modelOptions: [String],
        reasoningEffortOptions: [String],
        fastModeOptions: [String],
        preferencesLocked: Bool,
        preferencesChanged: @escaping () -> Void
    ) {
        _selectedModel = selectedModel
        _selectedReasoningEffort = selectedReasoningEffort
        _fastMode = fastMode
        self.modelOptions = modelOptions
        self.reasoningEffortOptions = reasoningEffortOptions
        self.fastModeOptions = fastModeOptions
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
                Menu {
                    Picker("Speed", selection: $fastMode) {
                        ForEach(fastModeOptions.reversed(), id: \.self) {
                            Text(fastModeTitle($0))
                                .tag($0)
                        }
                    }
                } label: {
                    Text("Speed")
                    Text(fastModeTitle(fastMode))
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
                if fastMode != "standard" {
                    Image(systemName: "bolt.fill")
                }
                
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
        .onChange(of: fastMode) {
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
    
    private func fastModeTitle(_ mode: String) -> String {
        switch mode {
        case "standard": "Standard"
        case "fast": "Fast"
            
        default:
            mode
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
        fastMode: .constant("standard"),
        modelOptions: ["gpt-5"],
        reasoningEffortOptions: ["low", "medium", "high", "xhigh"],
        fastModeOptions: ["standard", "fast"],
        preferencesLocked: false,
        preferencesChanged: {}
    )
    .darkSchemePreferred()
}
