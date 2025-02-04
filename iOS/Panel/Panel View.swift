import ScrechKit
import PteroNet

struct PanelView: View {
    @EnvironmentObject private var settings: ValueStorage
    @State private var vm: PanelVM
    @State private var fileVM: FileTabVM
    @State private var startupVM: StartupVM
    @State private var backupVM: BackupVM
    @State private var databaseVM: DatabaseVM
    @State private var scheduleVM: ScheduleVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
        self.backupVM = BackupVM(id)
        self.databaseVM = DatabaseVM(id)
        self.scheduleVM = ScheduleVM(id)
        self.startupVM = StartupVM(id)
    }
    
    private let lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    var body: some View {
        TabView(selection: $settings.lastTabPanel) {
            if let server = vm.server {
                InfoTab(server)
                    .tab(.info)
                
                ConsoleTab(id)
                    .tab(.console)
                
                FileTab(id)
                    .environmentObject(fileVM)
                    .tab(.files)
                
                DataTab(server)
                    .environment(backupVM)
                    .environment(databaseVM)
                    .environment(scheduleVM)
                    .tab(.backup)
                
                StartupView(server)
                    .environment(startupVM)
                    .tab(.startup)
            }
        }
        .sidebarAdaptableTabView()
        .environment(vm)
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
        
        vm.consoleDetails { data in
            if let data {
                vm.connectWebSocket(data)
            }
        }
        
        if !lowPowerMode {
            fileVM.fetchFiles()
            backupVM.fetchBackups()
            databaseVM.fetchDatabases()
            scheduleVM.fetchSchedules()
            startupVM.fetchStartupVariables()
        }
        
        vm.updateBackups = {
            backupVM.fetchBackups()
        }
    }
}

#Preview {
    PanelView("")
        .environmentObject(ValueStorage())
}
