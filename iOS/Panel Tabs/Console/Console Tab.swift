import ScrechKit

struct ConsoleTab: View {
    @State private var vm: ConsoleVM
    @Environment(PanelVM.self) private var panelVM
    @EnvironmentObject private var store: ValueStore
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = ConsoleVM(id)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            ConsoleView()
            
            HStack {
                TextField("Type a command...", text: $vm.command)
                    .monospaced()
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .onSubmit {
                        vm.sendCommand()
                    }
                
                if !vm.command.isEmpty {
                    SFButton("delete.left") {
                        vm.command = ""
                    }
                }
            }
            .animation(.default, value: vm.command)
            .padding(.bottom)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            vm.fontSize = store.consoleFontSize
        }
        .onDisappear {
            store.consoleFontSize = vm.fontSize
        }
        .inspector($vm.inspectorPresented) {
            ConsoleInspector()
        }
        .alert("Are you sure you want to perform the Kill action?", isPresented: $vm.alertKill) {
            Button("Kill", role: .destructive) {
                panelVM.changePower(.kill)
            }
        }
        .overlay {
            ConsoleOverlay(id)
            
            if panelVM.searchedMessages.isEmpty {
                if panelVM.searchRule.isEmpty {
                    ContentUnavailableView("Console is empty", systemImage: "apple.terminal")
                } else {
                    ContentUnavailableView.search(text: panelVM.searchRule)
                }
            }
        }
        .environment(vm)
        .environment(panelVM)
    }
}

#Preview {
    ConsoleTab("500028e3")
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
