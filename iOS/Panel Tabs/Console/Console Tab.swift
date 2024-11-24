import ScrechKit

struct ConsoleTab: View {
    @Environment(PanelVM.self) private var panelVM
    @EnvironmentObject private var settings: ValueStorage
    
    private var vm: ConsoleVM
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = ConsoleVM(id)
    }
    
    @State private var fontDesign: Font.Design = .monospaced
    
    private let fontSizes = [8, 10, 12, 14]
    private let fontDesigns: [Font.Design] = [
        .default,
        .monospaced,
        .rounded,
        .serif
    ]
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            ConsoleView(fontDesign)
        }
        .inspector($vm.inspectorPresented) {
            ConsoleInspector()
        }
        .overlay(alignment: .bottom) {
            ConsoleOverlay(id)
            
            if panelVM.searchedMessages.isEmpty {
                if panelVM.searchRule.isEmpty {
                    ContentUnavailableView("Console is empty",
                                           systemImage: "apple.terminal"
                    )
                } else {
                    ContentUnavailableView.search(text: panelVM.searchRule)
                }
            }
        }
        .environment(vm)
        .environment(panelVM)
        .toolbarBackground(.visible,
                           for: .tabBar)
        .toolbarBackground(.visible,
                           for: .navigationBar)
        .onAppear {
            vm.fontSize = settings.consoleFontSize
        }
        .onDisappear {
            settings.consoleFontSize = vm.fontSize
        }
        .alert("Are you sure you want to perform the Kill action?", isPresented: $vm.alertKill) {
            Button("Kill", role: .destructive) {
                panelVM.changePower(.kill)
            }
        }
    }
}

#Preview {
    ConsoleTab("500028e3")
        .environment(PanelVM(""))
        .environmentObject(ValueStorage())
}
