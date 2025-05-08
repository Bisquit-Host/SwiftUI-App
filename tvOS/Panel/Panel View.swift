import ScrechKit
import PteroNet

struct PanelView: View {
    private var vm: PanelVM
    private var fileVM: FileTabVM
    private var backupVM: BackupVM
    private var databaseVM: DatabaseVM
    private var scheduleVM: ScheduleVM
    private var subdomainVM: SubdomainVM
    private var usersVM: UsersVM
    private var logVM: LogVM
    private var allocationVM: AllocationVM
    private var startupVM: StartupVM
    
    private let server: ServerAttributes
    private let id: String
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.id = server.id
        
        self.backupVM = BackupVM(id)
        self.databaseVM = DatabaseVM(id)
        self.scheduleVM = ScheduleVM(id)
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
        self.subdomainVM = SubdomainVM(id)
        self.usersVM = UsersVM(id)
        self.logVM = LogVM(id)
        self.allocationVM = AllocationVM(id)
        self.startupVM = StartupVM(id)
    }
    
    @AppStorage("tab_panel") private var tabPanel: PanelTab = .info
    
    private var allocations: [AllocationAttributes] {
        server.relationships.allocations.data.map(\.attributes)
    }
    
    var body: some View {
        TabView(selection: $tabPanel) {
            if let server = vm.server {
                StatsTab(server)
                    .environment(vm)
                    .environment(backupVM)
                    .environment(databaseVM)
                    .tag(PanelTab.info)
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
                
                FileTab(id)
                    .environmentObject(fileVM)
                    .tag(PanelTab.files)
                    .tabItem {
                        Label("Files", systemImage: "folder")
                    }
                
                DataTab(server)
                    .environment(backupVM)
                    .environment(databaseVM)
                    .environment(scheduleVM)
                    .tag(PanelTab.backups)
                    .tabItem {
                        Label("Data", systemImage: "archivebox")
                    }
                
                UserList()
                    .environment(usersVM)
                    .tag(PanelTab.users)
                    .tabItem {
                        Label("Users", systemImage: "person")
                    }
                
                LogList()
                    .environment(logVM)
                    .tag(PanelTab.logs)
                    .tabItem {
                        Label("Logs", systemImage: "terminal")
                    }
                
                AllocationList(server)
                    .environment(allocationVM)
                    .tag(PanelTab.allocations)
                    .tabItem {
                        Label("Allocations", systemImage: "network")
                    }
                
                StartupList()
                    .environment(startupVM)
                    .tag(PanelTab.startup)
                    .tabItem {
                        Label("Startup", systemImage: "airplane")
                    }
                
                SubdomainList(allocations)
                    .environment(subdomainVM)
                    .tag(PanelTab.subdomains)
                    .tabItem {
                        Label("Subdomains", systemImage: "globe")
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
        
        if !System.lowPowerMode {
            fileVM.fetchFiles()
            backupVM.fetchBackups()
            databaseVM.fetchDatabases()
            scheduleVM.fetchSchedules()
            usersVM.fetchUsers(true)
            logVM.fetchLogs(true)
            allocationVM.fetchAllocations()
            startupVM.fetchStartupVariables()
            
            Task {
                await subdomainVM.fetchSubdomains()
            }
        }
        
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
    PanelView(PreviewProp.serverAttributes)
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
        .environment(ScheduleVM(""))
}
