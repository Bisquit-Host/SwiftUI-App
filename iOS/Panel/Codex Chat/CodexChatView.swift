import ScrechKit

struct CodexChatView: View {
    @State private var vm: CodexChatVM
    @Environment(\.openURL) private var openURL
    private let showsDismissButton: Bool
    
    init(serverId: String? = nil, showsDismissButton: Bool = true) {
        self.showsDismissButton = showsDismissButton
        _vm = State(initialValue: CodexChatVM(serverId: serverId))
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
                                CodexChatMessageRow(message: $0)
                                    .id($0.id)
                            }
                            
                            if let pendingApproval = vm.pendingApproval {
                                CodexPendingApprovalView(approval: pendingApproval)
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
                
                CodexChatInputBar()
            }
        }
        .environment(vm)
        .background {
            if vm.siriAnimationEnabled {
                CodexChatSiriBackground(isGenerating: vm.isWaitingForMessage)
            }
        }
        .navigationTitle(navigationTitle)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            if showsDismissButton {
                ToolbarItemGroup(placement: .topBarLeading) {
                    DismissButton()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("clock.arrow.circlepath") {
                    vm.chatHistoryPresented = true
                }
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
        .sheet($vm.chatHistoryPresented) {
            NavigationStack {
                CodexChatHistory()
            }
            .environment(vm)
        }
        .task {
            await vm.load()
        }
        .refreshable {
            refresh()
        }
        .task(id: vm.phase) {
            while vm.shouldPoll {
                try? await Task.sleep(for: .seconds(3))
                await vm.refresh()
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
        CodexChatView()
    }
    .darkSchemePreferred()
}
