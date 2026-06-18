import ScrechKit
import PteroNet

struct PanelView: View {
    @State private var vm: PanelVM
    @State private var fileVM: FileTabVM
    @State private var startupVM: StartupVM
    @State private var backupVM: BackupVM
    @State private var databaseVM: DatabaseVM
    @State private var scheduleVM: ScheduleVM
    @State private var consoleVM: ConsoleVM
    @State private var versionChangerVM: VersionChangerVM
    @State private var modInstallerVM: ModInstallerVM
    @State private var pluginInstallerVM: PluginInstallerVM
    @State private var modpackInstallerVM: ModpackInstallerVM
    @State private var usersVM: UsersVM
    @State private var logVM: LogVM
    @State private var subdomainVM: SubdomainVM
    @State private var selectedTab: Tabs = .info
    @State private var navigationTitleOpacity = 1.0
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = PanelVM(id)
        fileVM = FileTabVM(id)
        startupVM = StartupVM(id)
        backupVM = BackupVM(id)
        databaseVM = DatabaseVM(id)
        scheduleVM = ScheduleVM(id)
        consoleVM = ConsoleVM(id)
        versionChangerVM = VersionChangerVM(id)
        modInstallerVM = ModInstallerVM(id)
        pluginInstallerVM = PluginInstallerVM(id)
        modpackInstallerVM = ModpackInstallerVM(id)
        usersVM = UsersVM(id)
        logVM = LogVM(id)
        subdomainVM = SubdomainVM(id)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        PanelSidebarView(selectedTab: $selectedTab, navigationTitleOpacity: $navigationTitleOpacity)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(selectedTab.title)
                        .opacity(navigationTitleOpacity)
                        .animation(.snappy(duration: 0.25, extraBounce: 0), value: navigationTitleOpacity)
                        .accessibilityHidden(navigationTitleOpacity == 0)
                }
            }
            .environment(vm)
            .environmentObject(fileVM)
            .environment(consoleVM)
            .environment(backupVM)
            .environment(databaseVM)
            .environment(scheduleVM)
            .environment(startupVM)
            .environment(versionChangerVM)
            .environment(modInstallerVM)
            .environment(pluginInstallerVM)
            .environment(modpackInstallerVM)
            .environment(usersVM)
            .environment(logVM)
            .environment(subdomainVM)
            .task {
                await fetchData()
            }
            .onDisappear {
                vm.disconnectWebSocket()
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIApplication.willResignActiveNotification) {
                    vm.disconnectWebSocket()
                    vm.messages.removeAll()
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
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
            async let files:     () = fileVM.fetchFiles()
            async let startup:   () = startupVM.fetchStartupVariables()
            async let schedules: () = scheduleVM.fetchSchedules()
            async let backups:   () = backupVM.fetchBackups()
            async let databases: () = databaseVM.fetchDatabases()
            
            _ = await (files, startup, schedules, backups, databases)
        }
        
        vm.updateBackups = {
            await backupVM.fetchBackups()
        }
    }
}

#Preview {
    NavigationStack {
        PanelView("")
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
