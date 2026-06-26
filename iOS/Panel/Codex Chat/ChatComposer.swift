import ScrechKit

@available(iOS 26, macOS 26, *)
struct ChatComposer: View {
    @Binding private var prompt: String
    @Binding private var selectedModel: String
    @Binding private var selectedReasoningEffort: String
    @FocusState.Binding private var isFocused: Bool
    private let isResponding: Bool
    private let modelOptions: [String]
    private let reasoningEffortOptions: [String]
    private let sendPrompt: () -> Void
    private let preferencesChanged: () -> Void
    private let stopAction: (() -> Void)?
    
    init(
        prompt: Binding<String>,
        isResponding: Bool,
        selectedModel: Binding<String>,
        selectedReasoningEffort: Binding<String>,
        modelOptions: [String],
        reasoningEffortOptions: [String],
        isFocused: FocusState<Bool>.Binding,
        sendPrompt: @escaping () -> Void,
        preferencesChanged: @escaping () -> Void,
        stopAction: (() -> Void)? = nil
    ) {
        _prompt = prompt
        _selectedModel = selectedModel
        _selectedReasoningEffort = selectedReasoningEffort
        _isFocused = isFocused
        self.isResponding = isResponding
        self.modelOptions = modelOptions
        self.reasoningEffortOptions = reasoningEffortOptions
        self.sendPrompt = sendPrompt
        self.preferencesChanged = preferencesChanged
        self.stopAction = stopAction
    }
    
    private var sendButtonDisabled: Bool {
        isResponding || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack {
            TextField("Ask Codex", text: $prompt)
                .onSubmit(sendPrompt)
                .frame(height: 35)
                .padding(.horizontal, 10)
                .focused($isFocused)
                .submitLabel(.send)
                .disabled(isResponding)
            
            HStack(spacing: 16) {
                Spacer()
                
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
                .disabled(isResponding)
                .onChange(of: selectedModel) {
                    preferencesChanged()
                }
                .onChange(of: selectedReasoningEffort) {
                    preferencesChanged()
                }
                
                if isResponding, let stopAction {
                    Button("Stop", systemImage: "stop.circle.fill", role: .destructive, action: stopAction)
                        .frame(35)
                        .title()
                        .contentShape(.rect)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.red)
                } else {
                    Button("Send", systemImage: "arrow.up.circle.fill", action: sendPrompt)
                        .frame(35)
                        .title()
                        .contentShape(.rect)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(sendButtonDisabled ? .secondary : .primary)
                        .disabled(sendButtonDisabled)
                }
            }
        }
        .padding(5)
#if !os(visionOS)
        .glassEffect(in: .rect(cornerRadius: 16))
#endif
        .padding()
    }
    
    private func reasoningEffortTitle(_ effort: String) -> String {
        switch effort {
        case "low": "Light"
        case "medium": "Medium"
        case "high": "High"
        case "extra_high": "Extra High"
            
        default:
            effort
                .split(separator: "_")
                .map(\.capitalized)
                .joined(separator: " ")
        }
    }
}
