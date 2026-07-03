import ScrechKit

@available(iOS 26, macOS 26, *)
struct ChatComposer: View {
    @Binding private var prompt: String
    @Binding private var selectedModel: String
    @Binding private var selectedReasoningEffort: String
    @Binding private var webSearchEnabled: Bool
    @Binding private var fullAccess: Bool
    @FocusState.Binding private var isFocused: Bool
    private let isResponding: Bool
    private let preferencesLocked: Bool
    private let modelOptions: [String]
    private let reasoningEffortOptions: [String]
    private let sendPrompt: () -> Void
    private let preferencesChanged: () -> Void
    private let logout: () -> Void
    private let stopAction: (() -> Void)?
    
    init(
        prompt: Binding<String>,
        isResponding: Bool,
        selectedModel: Binding<String>,
        selectedReasoningEffort: Binding<String>,
        webSearchEnabled: Binding<Bool>,
        fullAccess: Binding<Bool>,
        modelOptions: [String],
        reasoningEffortOptions: [String],
        isFocused: FocusState<Bool>.Binding,
        preferencesLocked: Bool,
        sendPrompt: @escaping () -> Void,
        preferencesChanged: @escaping () -> Void,
        logout: @escaping () -> Void,
        stopAction: (() -> Void)? = nil
    ) {
        _prompt = prompt
        _selectedModel = selectedModel
        _selectedReasoningEffort = selectedReasoningEffort
        _webSearchEnabled = webSearchEnabled
        _fullAccess = fullAccess
        _isFocused = isFocused
        self.isResponding = isResponding
        self.preferencesLocked = preferencesLocked
        self.modelOptions = modelOptions
        self.reasoningEffortOptions = reasoningEffortOptions
        self.sendPrompt = sendPrompt
        self.preferencesChanged = preferencesChanged
        self.logout = logout
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
            
            HStack {
                ChatComposerSettingsMenu(
                    webSearchEnabled: $webSearchEnabled,
                    fullAccess: $fullAccess,
                    preferencesLocked: preferencesLocked,
                    preferencesChanged: preferencesChanged,
                    logout: logout
                )
                
                if fullAccess {
                    Image(systemName: "exclamationmark.shield")
                        .footnote()
                        .foregroundStyle(.orange)
                }
                
                Spacer()
                
                ChatComposerModelPicker(
                    selectedModel: $selectedModel,
                    selectedReasoningEffort: $selectedReasoningEffort,
                    modelOptions: modelOptions,
                    reasoningEffortOptions: reasoningEffortOptions,
                    preferencesLocked: preferencesLocked,
                    preferencesChanged: preferencesChanged
                )
                
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
}
