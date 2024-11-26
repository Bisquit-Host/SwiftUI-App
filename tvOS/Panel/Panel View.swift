import ScrechKit

struct PanelView: View {
    private var vm: PanelVM
    private var fileVM: FileTabVM
    private var backupVM: BackupVM
    private var databaseVM: DatabaseVM
    private var scheduleVM: ScheduleVM
    @EnvironmentObject private var settings: ValueStorage
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.backupVM = BackupVM(id)
        self.databaseVM = DatabaseVM(id)
        self.scheduleVM = ScheduleVM(id)
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
    }
    
    @AppStorage("tab_panel") private var tabPanel: Tab = .info
    
    var body: some View {
        TabView(selection: $tabPanel) {
            if let server = vm.server {
                StatsTab(server)
                    .environment(vm)
                    .environment(backupVM)
                    .environment(databaseVM)
                    .tag(Tab.info)
                    .tabItem {
                        Text("Stats")
                    }
                
                FileTab(id)
                    .environmentObject(fileVM)
                    .tag(Tab.files)
                    .tabItem {
                        Text("Files")
                    }
                
                DataTab(server)
                    .environment(backupVM)
                    .environment(databaseVM)
                    .environment(scheduleVM)
                    .tag(Tab.backups)
                    .tabItem {
                        Text("Data")
                    }
                
                InfoTab(id)
                    .tag(Tab.other)
                    .tabItem {
                        Text("Other")
                    }
            }
        }
        .task {
            fetchData()
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
    
    private func fetchData() {
        vm.fetchServerDetails()
        fileVM.fetchFiles()
        backupVM.fetchBackups()
        databaseVM.fetchDatabases()
        scheduleVM.fetchSchedules()
        
        vm.consoleDetails { data in
            if let data {
                vm.connectWebSocket(data)
            }
        }
        
        vm.updateBackups = {
            backupVM.fetchBackups()
        }
    }
}

#Preview {
    PanelView("")
        .environmentObject(ValueStorage())
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
        .environment(ScheduleVM(""))
}
