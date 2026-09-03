import ScrechKit

struct ChatComposer: View {
    @Environment(CodexChatVM.self) private var vm
    @Binding var presentation: ChatComposerPresentationState
    @FocusState private var isFocused: Bool
    
    private var sendButtonDisabled: Bool {
        isResponding
        || (vm.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && vm.pendingImages.isEmpty)
    }
    
    private var isResponding: Bool {
        vm.isSending || vm.shouldPoll
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            CodexChatImagePreviews(disabled: isResponding)
            
            TextField("Ask Codex", text: $vm.message)
                .onSubmit(send)
                .frame(height: 35)
                .padding(.horizontal, 10)
                .focused($isFocused)
                .submitLabel(.send)
                .disabled(isResponding)
            
            HStack {
                CodexChatImagePicker(disabled: isResponding)
                
                if vm.fullAccess {
                    Image(systemName: "exclamationmark.shield")
                        .footnote()
                        .foregroundStyle(.orange)
                }
                
                Spacer()
                
                if vm.provider == .builtIn {
                    ChatComposerBuiltInModelPicker()
                } else if vm.provider == .codex {
                    ChatComposerModelPickerAnchor(presentation: $presentation)
                }
                
                if isResponding {
                    Button("Stop", systemImage: "stop.circle.fill", role: .destructive, action: stop)
                        .frame(35)
                        .title()
                        .contentShape(.rect)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.red)
                } else {
                    Button("Send", systemImage: "arrow.up.circle.fill", action: send)
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
            presentation.composerFrame = $0
        }
        .task {
            isFocused = true
        }
    }
    
    private func send() {
        Task {
            await vm.sendMessage()
        }
    }
    
    private func stop() {
        Task {
            await vm.stop()
        }
    }
}
