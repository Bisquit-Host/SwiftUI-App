import ScrechKit

struct ConsoleTab: View {
    @State private var vm: ConsoleVM
    @Environment(PanelVM.self) private var panelVM
    @EnvironmentObject private var settings: ValueStorage
    
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
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            vm.fontSize = settings.consoleFontSize
        }
        .inspector($vm.inspectorPresented) {
            ConsoleInspector()
        }
        .onDisappear {
            settings.consoleFontSize = vm.fontSize
        }
        .alert("Are you sure you want to perform the Kill action?", isPresented: $vm.alertKill) {
            Button("Kill", role: .destructive) {
                panelVM.changePower(.kill)
            }
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
        .environment(vm)
        .environment(panelVM)
    }
}

#Preview {
    ConsoleTab("500028e3")
        .environment(PanelVM(""))
        .environmentObject(ValueStorage())
}
