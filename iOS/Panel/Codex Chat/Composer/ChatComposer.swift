import ScrechKit

@available(iOS 26, macOS 26, *)
struct ChatComposer: View {
    @Binding private var prompt: String
    @Binding private var selectedModel: String
    @Binding private var selectedReasoningEffort: String
    @Binding private var fastMode: String
    @Binding private var webSearchEnabled: Bool
    @Binding private var fullAccess: Bool
    @Binding private var modelPickerLayout: ModelPickerLayout
    @Binding private var modelPickerPresented: Bool
    @FocusState.Binding private var isFocused: Bool
    private let isResponding: Bool
    private let preferencesLocked: Bool
    private let modelOptions: [String]
    private let reasoningEffortOptions: [String]
    private let fastModeOptions: [String]
    private let sendPrompt: () -> Void
    private let preferencesChanged: () -> Void
    private let logout: () -> Void
    private let stopAction: (() -> Void)?
    
    init(
        prompt: Binding<String>,
        isResponding: Bool,
        selectedModel: Binding<String>,
        selectedReasoningEffort: Binding<String>,
        fastMode: Binding<String>,
        fastModeOptions: [String],
        webSearchEnabled: Binding<Bool>,
        fullAccess: Binding<Bool>,
        modelPickerLayout: Binding<ModelPickerLayout>,
        modelPickerPresented: Binding<Bool>,
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
        _fastMode = fastMode
        _webSearchEnabled = webSearchEnabled
        _fullAccess = fullAccess
        _modelPickerLayout = modelPickerLayout
        _modelPickerPresented = modelPickerPresented
        _isFocused = isFocused
        self.isResponding = isResponding
        self.preferencesLocked = preferencesLocked
        self.modelOptions = modelOptions
        self.reasoningEffortOptions = reasoningEffortOptions
        self.fastModeOptions = fastModeOptions
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

                ChatComposerModelPickerAnchor(
                    selectedModel: selectedModel,
                    selectedReasoningEffort: selectedReasoningEffort,
                    fastMode: fastMode,
                    layout: $modelPickerLayout,
                    isPresented: $modelPickerPresented
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
        .onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named("Codex chat"))
        } action: {
            modelPickerLayout.composerFrame = $0
        }
    }
}
