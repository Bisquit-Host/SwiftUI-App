import SwiftUI

struct PanelCodexChatView: View {
    @State private var vm = PanelCodexChatVM()
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            if !vm.configured {
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
                            if vm.messages.isEmpty {
                                ContentUnavailableView {
                                    Label {
                                        Text("Ask Codex about this panel")
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
                }
                
                PanelCodexChatInputBar()
            }
        }
        .environment(vm)
        .navigationTitle(vm.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                DismissButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("New Chat", systemImage: "square.and.pencil", action: createChat)
                    .disabled(vm.isLoading || vm.isSending)
            }
            
            ToolbarSpacer(.fixed)
            
            ToolbarItem(placement: .topBarTrailing) {
                if vm.shouldPoll {
                    Button("Stop", systemImage: "stop.fill", action: stop)
                }
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
        .overlay {
            if vm.isLoading && vm.messages.isEmpty {
                ProgressView()
                    .controlSize(.large)
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
    
    private func stop() {
        Task {
            await vm.stop()
        }
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let lastMessage = vm.messages.last else { return }
        
        proxy.scrollTo(lastMessage.id, anchor: .bottom)
    }
}

#Preview {
    NavigationStack {
        PanelCodexChatView()
    }
    .darkSchemePreferred()
}
