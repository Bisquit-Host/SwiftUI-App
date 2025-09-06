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
                        Label("Stats", systemImage: "gauge.open.with.lines.needle.33percent")
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
            await fetchData()
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            vm.disconnectWebSocket()
            vm.messages.removeAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                if let data = await vm.consoleDetails() {
                    vm.connectWebSocket(data)
                }
            }
        }
    }
    
    private func fetchData() async {
        await vm.fetchServerDetails()
        
        if let data = await vm.consoleDetails() {
            vm.connectWebSocket(data)
        }
        
        if !System.lowPowerMode {
            async let files: () = fileVM.fetchFiles()
            async let allocations: () = allocationVM.fetchAllocations()
            async let startup: () = startupVM.fetchStartupVariables()
            async let backups: () = backupVM.fetchBackups()
            async let databases: () = databaseVM.fetchDatabases()
            async let schedules: () = scheduleVM.fetchSchedules()
            async let users: () = usersVM.fetchUsers(true)
            async let logs: () = logVM.fetchLogs(true)
            async let subdomains: () = subdomainVM.fetchSubdomains()
            
            _ = await (
                files,
                allocations,
                startup,
                backups,
                databases,
                schedules,
                users,
                logs,
                subdomains
            )
        }
        
        vm.updateBackups = {
            await backupVM.fetchBackups()
        }
    }
}

#Preview {
    PanelView(PreviewProp.serverAttributes)
}
