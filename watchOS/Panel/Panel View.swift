import ScrechKit

struct PanelView: View {
    @EnvironmentObject private var settings: SettingsStorage
    private var vm: PanelVM
    private var fileVM: FileTabVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
    }
    
    var body: some View {
        TabView(selection: $settings.lastTabPanel) {
            if let server = vm.server {
                InfoTab(server)
                    .tag(Tab.info)
                
                Console()
                    .tag(Tab.console)
                
                FileTab(id)
                    .environmentObject(fileVM)
                    .tag(Tab.fileManager)
            }
        }
        .environment(vm)
        .task {
            vm.fetchServerDetails()
            
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
            
            fileVM.fetchFiles()
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
    }
}

#Preview {
    PanelView("")
        .environmentObject(SettingsStorage())
}
