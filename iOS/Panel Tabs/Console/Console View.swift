import ScrechKit

struct ConsoleView: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(PanelVM.self) private var panelVM
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack(alignment: .leading) {
                    ForEach(panelVM.searchedMessages.indices, id: \.self) { index in
                        let message = panelVM.searchedMessages[index]
                        
                        ConsoleMessage(message, index: index)
                    }
                }
                .padding(.bottom, 10)
                .textSelection(.enabled)
                .task {
                    delay {
                        if let _ = panelVM.searchedMessages.last {
                            withAnimation {
                                proxy.scrollTo(panelVM.searchedMessages.count - 1, anchor: .bottom)
                            }
                        }
                    }
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
        .environment(vm)
        .environment(panelVM)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ConsoleView()
        .environment(PanelVM(""))
}
