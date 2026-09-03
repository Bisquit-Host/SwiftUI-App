import ScrechKit

struct AgentChatHistory: View {
    @Environment(AgentChatVM.self) private var vm
    
    var body: some View {
        List {
            if vm.chatHistoryLoading {
                ProgressView()
                
            } else if vm.chatHistory.isEmpty {
                ContentUnavailableView("No chat history", systemImage: "clock.arrow.circlepath")
                
            } else {
                ForEach(vm.chatHistory) {
                    AgentChatHistoryRow($0)
                }
            }
        }
        .navigationTitle("Chat History")
        .toolbarTitleDisplayMode(.inline)
        .refreshableTask {
            await vm.fetchChatHistory()
        }
        .task {
            await vm.fetchChatHistory()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissButton()
            }
        }
    }
}

#Preview {
    AgentChatHistory()
        .darkSchemePreferred()
        .environment(AgentChatVM())
}
