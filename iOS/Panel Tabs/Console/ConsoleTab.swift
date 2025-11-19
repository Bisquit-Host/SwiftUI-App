import ScrechKit

struct ConsoleTab: View {
    @Environment(ConsoleVM.self) private var vm
    @Environment(PanelVM.self) private var panelVM
    @EnvironmentObject private var store: ValueStore
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        @Bindable var vm = vm
        @Bindable var panelVM = panelVM
        
        VStack(spacing: 0) {
            ConsoleView()
            
            HStack {
                PowerSwitch()
                    .padding(10)
                    .background(.ultraThinMaterial, in: .circle)
                    .overlay {
                        Circle()
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
                    .padding(.trailing, 10)
                
                TextField("Type a command...", text: $vm.command)
                    .monospaced()
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        sendCommand()
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
            
//            Task {
//                try await Task.sleep(for: .seconds(4))
//                
//                panelVM.measure()
//            }
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
    
    private func sendCommand() {
        if !vm.command.isEmpty {
            grantAchievement("send_console_message")
            
            Task {
                await vm.sendCommand()
            }
        }
    }
}

#Preview {
    ConsoleTab("")
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
        .environmentObject(ValueStore())
}
