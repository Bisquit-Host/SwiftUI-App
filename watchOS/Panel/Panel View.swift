import ScrechKit

struct PanelView: View {
    private var vm: PanelVM
    private var fileVM: FileTabVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
    }
    
    @AppStorage("panelTab") private var tab: PanelTab = .info
    
    var body: some View {
        TabView(selection: $tab) {
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
                vm.connectWebSocket(data)
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
        .environmentObject(ValueStore())
}
