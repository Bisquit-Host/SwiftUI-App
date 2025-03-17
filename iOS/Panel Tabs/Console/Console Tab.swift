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
        
        VStack(spacing: 0) {
            ConsoleView()
            
            HStack {
                TextField("Type a command...", text: $vm.command)
                    .monospaced()
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        if !vm.command.isEmpty {
                            vm.sendCommand()
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
        .background {
            Image(.darkBackgroundInfo)
                .resizable()
                .blur(radius: 55)
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
//        .overlay(alignment: .bottom) {
//            HStack {
//                TextField("Type a command...", text: $vm.command)
//                    .monospaced()
//                    .autocorrectionDisabled()
//                    .textInputAutocapitalization(.never)
//                    .onSubmit {
//                        if !vm.command.isEmpty {
//                            vm.sendCommand()
//                        }
//                    }
//                
//                if !vm.command.isEmpty {
//                    SFButton("delete.left") {
//                        vm.command = ""
//                    }
//                    .secondary()
//                }
//            }
//            .animation(.default, value: vm.command)
//            .padding()
//            .background(.ultraThinMaterial)
//        }
    }
}

#Preview {
    ConsoleTab("500028e3")
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
        .environmentObject(ValueStore())
}
