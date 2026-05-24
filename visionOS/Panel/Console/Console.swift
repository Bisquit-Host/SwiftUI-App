import ScrechKit

struct Console: View {
    @Environment(PanelVM.self) private var panelVM
    @Environment(\.openWindow) private var openWindow
    
    private var vm: ConsoleVM
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = ConsoleVM(id)
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
            ScrollView {
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
                        Task {
                            try await Task.sleep(for: .seconds(1))
                            
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
            .scrollIndicators(.never)
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
                ConsoleEmptyView()
            }
        }
    }
}

#Preview {
    Console("")
        .padding()
        .glassBackgroundEffect()
        .environment(PanelVM(""))
}
