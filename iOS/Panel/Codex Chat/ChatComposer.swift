import ScrechKit

@available(iOS 26, macOS 26, *)
struct ChatComposer: View {
    @Binding private var prompt: String
    @Binding private var isResponding: Bool
    @FocusState.Binding private var isFocused: Bool
    private let sendPrompt: () -> Void
    private let stopAction: (() -> Void)?
    
    init(
        prompt: Binding<String>,
        isResponding: Binding<Bool>,
        isFocused: FocusState<Bool>.Binding,
        sendPrompt: @escaping () -> Void,
        stopAction: (() -> Void)? = nil
    ) {
        _prompt = prompt
        _isResponding = isResponding
        _isFocused = isFocused
        self.sendPrompt = sendPrompt
        self.stopAction = stopAction
    }
    
    private var sendButtonDisabled: Bool {
        isResponding || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack {
            TextField("Type here...", text: $prompt)
                .onSubmit(sendPrompt)
                .frame(height: 35)
                .padding(.horizontal, 10)
                .focused($isFocused)
                .submitLabel(.send)
                .disabled(isResponding)
            
            HStack {
                if let stopAction {
                    Button("Stop", systemImage: "stop.fill", role: .destructive, action: stopAction)
                        .frame(35)
                        .tint(.red)
                        .labelStyle(.iconOnly)
                }
                
                Spacer()
                
                Button("Send", systemImage: "arrow.up.circle.fill", action: sendPrompt)
                    .frame(35)
                    .title()
                    .contentShape(.rect)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(sendButtonDisabled ? .secondary : .primary)
                    .disabled(sendButtonDisabled)
            }
        }
        .padding(5)
#if !os(visionOS)
        .glassEffect(in: .rect(cornerRadius: 16))
#endif
        .padding()
    }
}
