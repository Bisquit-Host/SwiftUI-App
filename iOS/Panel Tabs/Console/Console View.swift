import ScrechKit

struct ConsoleView: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(PanelVM.self) private var panelVM
    
    private let fontDesign: Font.Design
    @State private var lastMessageIndex = 0
    
    init(_ fontDesign: Font.Design = .monospaced) {
        self.fontDesign = fontDesign
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack(alignment: .leading) {
                    ForEach(panelVM.searchedMessages.indices, id: \.self) { index in
                        Text(panelVM.searchedMessages[index])
                            .fontDesign(fontDesign)
                            .fontSize(vm.fontSize)
                            .multilineTextAlignment(.leading)
                            .onAppear {
                                if index == panelVM.searchedMessages.count - 1 {
                                    lastMessageIndex = index
                                }
                            }
                    }
                }
                .padding(.bottom, 10)
                .textSelection(.enabled)
                .onAppear {
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
    ConsoleView()
        .environment(PanelVM(""))
}
