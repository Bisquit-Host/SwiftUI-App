import ScrechKit

struct ConsoleTab: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(PanelVM.self) private var panelVM
    @EnvironmentObject private var store: ValueStore
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private let width = UIScreen.main.bounds.width
    
    var body: some View {
        @Bindable var vm = vm
        @Bindable var panelVM = panelVM
        
        VStack(spacing: 0) {
            ConsoleView()
            
            HStack {
                PowerSwitch()
                    .scaleEffect(0.8)
                    .frame(35)
                    .padding(.trailing, 10)
                
                TextField("Type a command...", text: $vm.command)
                    .monospaced()
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        if !vm.command.isEmpty {
                            Task {
                                await vm.sendCommand()
                            }
                        }
                    }
                
                if !vm.command.isEmpty {
                    SFButton("delete.left") {
                        vm.command = ""
                    }
                    .secondary()
                }
            }
            .animation(.default, value: vm.command)
            .padding()
            .background(.ultraThinMaterial)
        }
        .task {
            vm.fontSize = store.consoleFontSize
        }
        .onDisappear {
            store.consoleFontSize = vm.fontSize
        }
        .inspector($vm.inspectorPresented) {
            ConsoleInspector()
        }
        .background(BackgroundImage())
        .alert("Are you sure you want to perform the Kill action?", isPresented: $vm.alertKill) {
            Button("Kill", role: .destructive) {
                Task {
                    await panelVM.changePower(.kill)
                }
            }
        }
        .overlay {
            if panelVM.searchedMessages.isEmpty {
                if panelVM.searchRule.isEmpty {
                    ContentUnavailableView("Console is empty", systemImage: "apple.terminal")
                } else {
                    ContentUnavailableView.search(text: panelVM.searchRule)
                }
            }
        }
    }
}

#Preview {
    ConsoleTab("500028e3")
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
        .environmentObject(ValueStore())
}
