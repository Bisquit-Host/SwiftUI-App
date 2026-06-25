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
            if store.consoleMessengerDesign {
                ConsoleMessengerView()
                ConsoleClassicInputBar(sendCommand: sendCommand)
            } else {
                ConsoleView()
                ConsoleClassicInputBar(sendCommand: sendCommand)
            }
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
        .sheet($vm.commandHistoryPresented) {
            NavigationStack {
                CommandHistory()
            }
        }
        .background(BackgroundImage())
        .alert("Are you sure you want to perform the Kill action?", isPresented: $vm.alertKill) {
            Button("Kill", role: .destructive, action: kill)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("clock.arrow.circlepath") {
                    vm.commandHistoryPresented = true
                }
            }
            
            ToolbarSpacer(placement: .topBarTrailing)
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("bold.italic.underline") {
                    vm.inspectorPresented = true
                }
            }
        }
    }
    
    private func kill() {
        Task {
            await panelVM.changePower(.kill)
        }
    }
    
    private func sendCommand() {
        vm.command = vm.command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !vm.command.isEmpty else { return }
        
        grantAchievement("send_console_message")
        
        Task {
            await vm.sendCommand()
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
