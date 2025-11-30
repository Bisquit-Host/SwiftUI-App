import ScrechKit

struct PanelView: View {
    @EnvironmentObject private var store: ValueStore
    private var vm: PanelVM
    private var fileVM: FileTabVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = PanelVM(id)
        fileVM = FileTabVM(id)
    }
    
    var body: some View {
        TabView(selection: $store.panelTab) {
            if let server = vm.server {
                InfoTab(server)
                    .tag(PanelTab.info)
                
                Console()
                    .tag(PanelTab.console)
                
                FileTab(id)
                    .environmentObject(fileVM)
                    .tag(PanelTab.files)
            }
        }
        .environment(vm)
        .task {
            await vm.fetchServerDetails()
            
            if let data = await vm.consoleDetails() {
                await MainActor.run {
                    vm.connectWebSocket(data)
                }
            }
            
            if !System.lowPowerMode {
                await fileVM.fetchFiles()
            }
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
    }
}

#Preview {
    PanelView("")
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
