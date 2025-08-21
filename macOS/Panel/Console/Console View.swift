import ScrechKit

struct ConsoleView: View {
    @Environment(PanelVM.self) private var panelVM
    private var vm: ConsoleVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = ConsoleVM(id)
    }
    
    @State private var lastMessageIndex = 0
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack(alignment: .leading) {
                    ForEach(panelVM.searchedMessages.indices, id: \.self) { index in
                        Text(panelVM.searchedMessages[index])
                        //                            .fontDesign(fontDesign)
                        //                            .fontSize(vm.fontSize)
                            .multilineTextAlignment(.leading)
                            .task {
                                if index == panelVM.searchedMessages.count - 1 {
                                    lastMessageIndex = index
                                }
                            }
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
                    if lastMessageIndex == panelVM.searchedMessages.count - 2 {
                        withAnimation {
                            proxy.scrollTo(panelVM.searchedMessages.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .padding(2)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ConsoleView("")
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
