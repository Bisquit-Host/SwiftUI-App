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
                                ContentUnavailableView("Ask Codex about this panel", systemImage: "sparkles")
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
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if vm.shouldPoll {
                    Button("Stop", systemImage: "stop.fill", action: stop)
                }

                Button("Refresh", systemImage: "arrow.clockwise", action: refresh)
                    .disabled(vm.isLoading)
            }
        }
        .task {
            await vm.load()
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
