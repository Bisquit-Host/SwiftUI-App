import ScrechKit

struct PanelView: View {
    private var vm: PanelVM
    private var fileVM: FileTabVM
    private var dataTabVM: DataTabVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.dataTabVM = DataTabVM(id)
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
    }
    
    @AppStorage("tab_panel") private var tabPanel: Tab = .info
    
    var body: some View {
        TabView(selection: $tabPanel) {
            if let server = vm.server {
                StatsTab(server)
                    .environment(vm)
                    .environment(dataTabVM)
                    .tag(Tab.info)
                    .tabItem {
                        Text("Stats")
                    }
                
                FileTab(id)
                    .environmentObject(fileVM)
                    .tag(Tab.fileManager)
                    .tabItem {
                        Text("Files")
                    }
                
                DataTab(server.id,
                        limits: server.featureLimits
                )
                .environment(dataTabVM)
                .tag(Tab.backup)
                .tabItem {
                    Text("Data")
                }
                
                InfoTab(server)
                    .tag(Tab.other)
                    .tabItem {
                        Text("Other")
                    }
            }
        }
        .task {
            vm.fetchServerDetails()
            fileVM.fetchFiles()
            dataTabVM.fetchData()
            
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
            
            vm.updateBackups = {
                dataTabVM.fetchBackups()
            }
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            vm.disconnectWebSocket()
            vm.messages.removeAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
        }
    }
}

#Preview {
    PanelView("")
        .environmentObject(SettingsStorage())
}
