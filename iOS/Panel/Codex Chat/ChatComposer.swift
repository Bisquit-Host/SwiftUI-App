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
        HStack {
            if let stopAction {
                Button("Stop", systemImage: "stop.fill", role: .destructive, action: stopAction)
                    .frame(35)
#if !os(visionOS)
                    .glassEffect()
#endif
                    .tint(.red)
                    .labelStyle(.iconOnly)
            }

            TextField("Type here...", text: $prompt)
                .onSubmit(sendPrompt)
                .frame(height: 35)
                .padding(.horizontal, 10)
#if !os(visionOS)
                .glassEffect()
#endif
                .focused($isFocused)
                .submitLabel(.send)
                .disabled(isResponding)

            Button("Send", systemImage: "paperplane", action: sendPrompt)
                .frame(35)
                .contentShape(.rect)
                .labelStyle(.iconOnly)
                .foregroundStyle(sendButtonDisabled ? .secondary : .primary)
#if !os(visionOS)
                .glassEffect()
#endif
                .disabled(sendButtonDisabled)
        }
        .padding()
    }
}
