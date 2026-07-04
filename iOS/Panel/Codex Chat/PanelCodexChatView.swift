import SwiftUI

struct PanelCodexChatView: View {
    @State private var vm: PanelCodexChatVM
    @Environment(\.openURL) private var openURL
    private let showsDismissButton: Bool

    init(serverId: String? = nil, showsDismissButton: Bool = true) {
        self.showsDismissButton = showsDismissButton
        _vm = State(initialValue: PanelCodexChatVM(serverId: serverId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading && vm.messages.isEmpty {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !vm.configured {
                ContentUnavailableView {
                    Label("Codex is not connected", systemImage: "sparkles")
                } description: {
                    Text("Connect Codex to start chatting")
                } actions: {
                    if vm.hasLoadedStatus {
                        Button("Connect Codex", systemImage: "link", action: connectCodex)
                            .buttonStyle(.borderedProminent)
                    }
                    
                    if let oauthStart = vm.oauthStart {
                        Text(oauthStart.userCode)
                            .monospaced()
                            .textSelection(.enabled)
                        
                        Button("Finish OAuth", systemImage: "checkmark", action: finishOAuth)
                    }
                }
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
                                PanelCodexChatMessageRow(message: $0)
                                    .id($0.id)
                            }
                            
                            if let pendingApproval = vm.pendingApproval {
                                PanelCodexPendingApprovalView(approval: pendingApproval)
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
                
                PanelCodexChatInputBar()
            }
        }
        .environment(vm)
        .background {
            if vm.siriAnimationEnabled {
                PanelCodexChatSiriBackground(isGenerating: vm.isWaitingForMessage)
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
                Button("New Chat", systemImage: "square.and.pencil", action: createChat)
                    .disabled(!vm.showsNewChatButton || vm.isCreatingChat || vm.isSending)
                    .opacity(vm.showsNewChatButton ? 1 : 0)
                    .accessibilityHidden(!vm.showsNewChatButton)
            }
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
        PanelCodexChatView()
    }
    .darkSchemePreferred()
}
