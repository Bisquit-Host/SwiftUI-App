import ScrechKit

struct Console: View {
    @Environment(PanelVM.self) private var panelVM
    
    @Environment(\.openWindow) private var openWindow
    
    private var vm: ConsoleVM
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = ConsoleVM(id)
    }
    
    @State private var lastMessageIndex = 0
    @State private var fontDesign: Font.Design = .monospaced
    
    //    private let fontSizes = [8, 10, 12, 14]
    //    private let fontDesigns: [Font.Design] = [
    //        .default,
    //        .monospaced,
    //        .rounded,
    //        .serif
    //    ]
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    VStack(alignment: .leading) {
                        ForEach(panelVM.searchedMessages.indices, id: \.self) { index in
                            Text(panelVM.searchedMessages[index])
                                .fontDesign(fontDesign)
                                .fontSize(vm.fontSize)
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
            .toolbar {
                Button("Open in a separate window", systemImage: "macwindow.on.rectangle") {
                    openWindow(id: "console")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
        .padding(.horizontal)
        .overlay {
            if panelVM.messages.isEmpty {
                ContentUnavailableView {
                    Label("Console is empty", systemImage: "apple.terminal")
                } description: {
                    Text("Launch the server to start receiving messages")
                } actions: {
                    Button("🚀") {
                        Task {
                            await panelVM.changePower(.start)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Console("")
        .darkSchemePreferred()
        .padding()
        .glassBackgroundEffect()
        .environment(PanelVM(""))
}
