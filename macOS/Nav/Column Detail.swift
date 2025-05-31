import SwiftUI
import PteroNet

struct ColumnDetail: View {
    @Environment(NavModel.self) private var nav
    @State private var vm: PanelVM
    @State private var fileVM: FileTabVM
    @State private var startupVM: StartupVM
    @State private var backupVM: BackupVM
    @State private var databaseVM: DatabaseVM
    @State private var scheduleVM: ScheduleVM
    @State private var consoleVM: ConsoleVM
    @State private var allocationVM: AllocationVM
    @State private var subdomainVM: SubdomainVM
    
    private let tab: PanelTab?
    private let server: ServerAttributes
    private var focusedList: FocusState<FocusedList?>.Binding
    
    init(
        _ tab: PanelTab? = nil,
        server: ServerAttributes,
        focusedList: FocusState<FocusedList?>.Binding
    ) {
        self.tab = tab
        self.server = server
        self.focusedList = focusedList
        
        let id = server.id
        vm = PanelVM(id)
        fileVM = FileTabVM(id)
        backupVM = BackupVM(id)
        databaseVM = DatabaseVM(id)
        scheduleVM = ScheduleVM(id)
        startupVM = StartupVM(id)
        consoleVM = ConsoleVM(id)
        allocationVM = AllocationVM(id)
        subdomainVM = SubdomainVM(id)
    }
    
    private var activeTab: PanelTab? {
        if let tab {
            tab
        } else {
            nav.selectedTab
        }
    }
    
    var body: some View {
        VStack {
            if let server = nav.selectedServers.first {
                let id = server.id
                
                switch activeTab {
                case .logs:
                    LogList(id)
                    
                case .allocations:
                    AllocationList(id)
                        .environment(allocationVM)
                    
                case .databases:
                    DatabaseList(id)
                        .environment(databaseVM)
                    
                case .backups:
                    BackupList(server)
                        .environment(backupVM)
                    
                case .files:
                    FileTab(id)
                        .environmentObject(fileVM)
                    
                case .schedules:
                    ScheduleList(id)
                        .environment(scheduleVM)
                    
                case .startup:
                    StartupList(id)
                    
                case .console:
                    ConsoleView(id)
                        .environment(vm)
                    
                case .subdomains:
                    SubdomainList()
                        .environment(subdomainVM)
                    
                case .users:
                    UserList(id)
                    
                case nil:
                    Text("Select a section")
                    
                default:
                    Text("Oops...")
                }
            }
        }
        .frame(minWidth: 300)
        .environment(vm)
        .task {
            await fetchData()
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
    }
    
    private func fetchData() async {
        await vm.fetchServerDetails()
        
        vm.consoleDetails { data in
            if let data {
                vm.connectWebSocket(data)
            }
        }
        
        if !System.lowPowerMode {
            fileVM.fetchFiles()
            backupVM.fetchBackups()
            databaseVM.fetchDatabases()
            scheduleVM.fetchSchedules()
            startupVM.fetchStartupVariables()
            
            Task {
                await subdomainVM.fetchSubdomains()
            }
        }
        
        vm.updateBackups = {
            backupVM.fetchBackups()
        }
    }
}

//#Preview {
//    ColumnDetail(server: PreviewProp.serverAttributes)
//}
