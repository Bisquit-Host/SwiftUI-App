import ScrechKit

struct AgentChatView: View {
    @State private var vm: AgentChatVM
    @State private var composerPresentation = ChatComposerPresentationState()
    @EnvironmentObject private var store: ValueStore
    @Environment(\.openURL) private var openURL
    private let showsDismissButton: Bool
    
    init(serverId: String? = nil, showsDismissButton: Bool = true) {
        self.showsDismissButton = showsDismissButton
        _vm = State(initialValue: AgentChatVM(serverId: serverId))
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack(spacing: 0) {
            if vm.isLoading && vm.messages.isEmpty {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !vm.configured {
                CodexDisconnectedView(
                    hasLoadedStatus: vm.hasLoadedStatus,
                    userCode: vm.oauthStart?.userCode,
                    connectCodex: connectCodex,
                    finishOAuth: finishOAuth
                )
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            if vm.messages.isEmpty && !vm.isWaitingForMessage {
                                ContentUnavailableView {
                                    Label {
                                        Text("Ask anything")
                                    } icon: {
                                        Image(systemName: "siri")
                                            .foregroundStyle(.orange.gradient)
                                    }
                                }
                                .containerRelativeFrame(.vertical)
                                .frame(maxWidth: .infinity)
                            }
                            
                            ForEach(vm.messages) {
                                AgentChatMessageRow(message: $0)
                                    .id($0.id)
                            }
                            
                            if let pendingApproval = vm.pendingApproval {
                                AgentPendingApprovalView(approval: pendingApproval)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: vm.messages) {
                        scrollToBottom(proxy)
                    }
                    .onChange(of: vm.isWaitingForMessage) {
                        scrollToBottom(proxy)
                    }
                }
                
                ChatComposer(presentation: $composerPresentation)
            }
        }
        .overlay {
            if vm.configured && vm.provider == .codex {
                ChatComposerModelPicker(presentation: $composerPresentation)
            }
        }
        .coordinateSpace(.named("Agent chat"))
        .navigationTitle(navigationTitle)
        .toolbarTitleDisplayMode(.inline)
        .environment(vm)
        .task {
            await vm.load()
        }
        .refreshable {
            refresh()
        }
        .onChange(of: store.bigAssAnimations) {
            vm.syncAnimationState()
        }
        .onChange(of: vm.provider) {
            composerPresentation.isModelPickerPresented = false
        }
        .task(id: vm.phase) {
            while vm.shouldPoll {
                try? await Task.sleep(for: .seconds(3))
                await vm.refresh()
            }
        }
        .sheet($vm.settingsPresented) {
            AgentChatSettingsSheet()
                .environment(vm)
        }
        .background {
            if store.bigAssAnimations {
                AgentChatSiriBackground(isGenerating: vm.isWaitingForMessage)
            }
        }
        .toolbar {
            if showsDismissButton {
                ToolbarItemGroup(placement: .topBarLeading) {
                    DismissButton()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gear", action: showSettings)
            }
#if !os(visionOS)
            ToolbarSpacer(placement: .topBarTrailing)
#endif
            ToolbarItem(placement: .topBarTrailing) {
                Button("New Chat", systemImage: "square.and.pencil", action: createChat)
                    .disabled(!vm.showsNewChatButton || vm.isCreatingChat || vm.isSending)
                    .opacity(vm.showsNewChatButton ? 1 : 0)
                    .accessibilityHidden(!vm.showsNewChatButton)
            }
        }
    }
    
    private func connectCodex() {
        Task {
            if let url = await vm.startCodexOAuth() {
                openURL(url)
            }
        }
    }
    
    private func finishOAuth() {
        Task {
            await vm.finishCodexOAuth()
        }
    }
    
    private func createChat() {
        Task {
            await vm.createChat()
        }
    }
    
    private func showSettings() {
        vm.settingsPresented = true
    }
    
    private func refresh() {
        Task {
            await vm.refresh()
        }
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let lastMessage = vm.messages.last else { return }
        
        proxy.scrollTo(lastMessage.id, anchor: .bottom)
    }
    
    private var navigationTitle: String {
        guard vm.messages.isEmpty && !vm.isWaitingForMessage else {
            return ""
        }
        
        return String(localized: "New Chat")
    }
}

#Preview {
    NavigationStack {
        AgentChatView()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
