import ScrechKit

struct ConsoleMessengerView: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(PanelVM.self) private var panelVM
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(panelVM.searchedMessages.indices, id: \.self) { index in
                        ConsoleMessengerMessage(panelVM.searchedMessages[index], index: index)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .textSelection(.enabled)
                .task {
                    await scrollToBottom(proxy)
                }
                .onChange(of: panelVM.searchedMessages) {
                    if vm.lastMessageIndex == panelVM.searchedMessages.count - 2 {
                        withAnimation {
                            proxy.scrollTo(panelVM.searchedMessages.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .scrollIndicators(.never)
        .ignoresSafeArea(.keyboard)
    }
}

private extension ConsoleMessengerView {
    func scrollToBottom(_ proxy: ScrollViewProxy) async {
        try? await Task.sleep(for: .seconds(1))
        guard panelVM.searchedMessages.isEmpty == false else { return }
        
        withAnimation {
            proxy.scrollTo(panelVM.searchedMessages.count - 1, anchor: .bottom)
        }
    }
}

#Preview {
    ConsoleMessengerView()
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
}
