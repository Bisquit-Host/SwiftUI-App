import ScrechKit

struct ConsoleTab: View {
    @Environment(PanelVM.self) private var panelVM
    @EnvironmentObject private var settings: ValueStorage
    @State private var vm: ConsoleVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = ConsoleVM(id)
    }
        
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            ConsoleView()
        }
        .environment(vm)
        .environment(panelVM)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            vm.fontSize = settings.consoleFontSize
        }
        .onDisappear {
            settings.consoleFontSize = vm.fontSize
        }
        .inspector($vm.inspectorPresented) {
            ConsoleInspector()
        }
        .overlay(alignment: .bottom) {
            ConsoleOverlay(id)
            
            if panelVM.searchedMessages.isEmpty {
                if panelVM.searchRule.isEmpty {
                    ContentUnavailableView("Console is empty", systemImage: "apple.terminal")
                } else {
                    ContentUnavailableView.search(text: panelVM.searchRule)
                }
            }
        }
        .alert("Are you sure you want to perform the Kill action?", isPresented: $vm.alertKill) {
            Button("Kill", role: .destructive) {
                panelVM.changePower(.kill)
            }
        }
        .toolbar {
            
        }
    }
}

#Preview {
    ConsoleTab("500028e3")
        .environment(PanelVM(""))
        .environmentObject(ValueStorage())
}
