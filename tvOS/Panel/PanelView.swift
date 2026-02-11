import ScrechKit
import PteroNet

struct PanelView: View {
    @EnvironmentObject private var store: ValueStore
    
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
        
        backupVM = BackupVM(id)
        databaseVM = DatabaseVM(id)
        scheduleVM = ScheduleVM(id)
        vm = PanelVM(id)
        fileVM = FileTabVM(id)
        subdomainVM = SubdomainVM(id)
        usersVM = UsersVM(id)
        logVM = LogVM(id)
        allocationVM = AllocationVM(id)
        startupVM = StartupVM(id)
    }
    
    var body: some View {
        let allocations = server.relationships.allocations.data.map(\.attributes)
        
        TabView(selection: $store.panelTab) {
            if let server = vm.server {
                Tab("Stats", systemImage: "gauge.open.with.lines.needle.33percent", value: PanelTab.info) {
                    StatsTab(server)
                        .environment(vm)
                        .environment(backupVM)
                        .environment(databaseVM)
                }
                
                Tab("Files", systemImage: "folder", value: PanelTab.files) {
                    FileTab(id)
                        .environmentObject(fileVM)
                }
                
                Tab("Data", systemImage: "archivebox", value: PanelTab.backups) {
                    DataTab(server)
                        .environment(backupVM)
                        .environment(databaseVM)
                        .environment(scheduleVM)
                }
                
                Tab("Users", systemImage: "person", value: PanelTab.users) {
                    UserList()
                        .environment(usersVM)
                }
                
                Tab("Logs", systemImage: "terminal", value: PanelTab.logs) {
                    LogList()
                        .environment(logVM)
                }
                
                Tab("Ports", systemImage: "network", value: PanelTab.allocations) {
                    AllocationList(server)
                        .environment(allocationVM)
                }
                
                Tab("Startup", systemImage: "airplane", value: PanelTab.startup) {
                    StartupList()
                        .environment(startupVM)
                }
                
                if self.server.eggId == 34 {
                    Tab("Subdomains", systemImage: "globe", value: PanelTab.subdomains) {
                        SubdomainList(allocations)
                            .environment(subdomainVM)
                    }
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
            
            if server.eggId == 34 {
                async let subdomains: () = subdomainVM.fetchSubdomains()
                
                _ = await (
                    files, allocations, startup,
                    backups, databases, schedules,
                    users, logs, subdomains
                )
            } else {
                _ = await (
                    files, allocations, startup,
                    backups, databases, schedules,
                    users, logs
                )
            }
        }
        
        vm.updateBackups = { await backupVM.fetchBackups() }
    }
}

#Preview {
    PanelView(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
