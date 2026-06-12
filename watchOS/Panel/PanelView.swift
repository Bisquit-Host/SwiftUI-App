import ScrechKit

struct PanelView: View {
    @EnvironmentObject private var store: ValueStore
    private var vm: PanelVM
    private var fileVM: FileTabVM
    private var usersVM: UsersVM
    private var logVM: LogVM
    private var backupVM: BackupVM
    private var databaseVM: DatabaseVM
    private var allocationVM: AllocationVM
    private var startupVM: StartupVM
    
    private let id: String
    @State private var selectedTab: PanelTab = .console
    @State private var isTabNavigationPresented = false
    
    init(_ id: String) {
        self.id = id
        vm = PanelVM(id)
        fileVM = FileTabVM(id)
        usersVM = UsersVM(id)
        logVM = LogVM(id)
        backupVM = BackupVM(id)
        databaseVM = DatabaseVM(id)
        allocationVM = AllocationVM(id)
        startupVM = StartupVM(id)
    }
    
    var body: some View {
        Group {
            if vm.server != nil {
                switch selectedTab {
                case .console:
                    Console()
                    
                case .files:
                    FileTab(id)
                        .environmentObject(fileVM)
                    
                case .users:
                    UserListParent()
                        .environment(usersVM)
                    
                case .logs:
                    LogListParent()
                        .environment(logVM)
                    
                case .backups:
                    if let server = vm.server {
                        BackupTab(server)
                            .environment(backupVM)
                    }
                    
                case .databases:
                    if let server = vm.server {
                        DatabaseTab(server)
                            .environment(databaseVM)
                    }
                    
                case .allocations:
                    if let server = vm.server {
                        AllocationTab(server)
                            .environment(allocationVM)
                    }
                    
                case .startup:
                    StartupList()
                        .environment(startupVM)
                    
                default:
                    Console()
                }
            } else {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Tabs", systemImage: "square.grid.2x2") {
                    isTabNavigationPresented = true
                }
            }
        }
        .sheet($isTabNavigationPresented) {
            PanelTabNavigationSheet(selectedTab: $selectedTab)
        }
        .environment(vm)
        .onAppear {
            switch store.panelTab {
            case .console, .files, .backups, .users, .logs, .databases, .allocations, .startup:
                selectedTab = store.panelTab
                
            default:
                store.panelTab = .console
                selectedTab = .console
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            store.panelTab = newValue
        }
        .task {
            await vm.fetchServerDetails()
            
            if let data = await vm.consoleDetails() {
                vm.connectWebSocket(data)
            }
            
            if !System.lowPowerMode {
                await fileVM.fetchFiles()
            }
            
            await backupVM.fetchBackups()
            await databaseVM.fetchDatabases()
            await allocationVM.fetchAllocations()
            await startupVM.fetchStartupVariables()
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
