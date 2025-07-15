import ScrechKit
import PteroNet

struct PanelView: View {
    @EnvironmentObject private var store: ValueStore
    @State private var vm: PanelVM
    @State private var fileVM: FileTabVM
    @State private var startupVM: StartupVM
    @State private var backupVM: BackupVM
    @State private var databaseVM: DatabaseVM
    @State private var scheduleVM: ScheduleVM
    @State private var consoleVM: ConsoleVM
    
    @Environment(\.dismiss) private var dismiss
    
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
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            if UIDevice.current.userInterfaceIdiom == .pad {
                panel
            } else {
                NavigationView {
                    panel
                }
            }
        }
        .navigationTitle(vm.server?.name ?? "")
        .navigationSubtitle(vm.server?.description ?? "")
        .panelToolbar()
        .environment(consoleVM)
        .environmentObject(fileVM)
        .environment(backupVM)
        .environment(databaseVM)
        .environment(scheduleVM)
        .environment(startupVM)
        .environment(vm)
        .ignoresSafeArea()
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
        .alert(isPresented: $vm.alertNewFolder) {
            CustomDialog(
                title: "New Folder",
                button1: .init(content: "Create", foreground: .white) { folder in
                    if !folder.isEmpty {
                        Task {
                            await fileVM.createFolder(folder, at: fileVM.path)
                        }
                    }
                    
                    vm.alertNewFolder = false
                },
                button2: .init(content: "Cancel", foreground: .red) { _ in
                    vm.alertNewFolder = false
                },
                addsTextField: true,
                textFieldHint: "Enter a folder name"
            )
            .transition(.blurReplace.combined(with: .scale(0.8)))
        }
    }
    
    private func fetchData() async {
        await vm.fetchServerDetails()
        
        if let data = await vm.consoleDetails() {
            vm.connectWebSocket(data)
        }
        
        if !System.lowPowerMode {
            async let files: () =     fileVM.fetchFiles()
            async let startup: () =   startupVM.fetchStartupVariables()
            async let schedules: () = scheduleVM.fetchSchedules()
            async let backups: () =   backupVM.fetchBackups()
            async let databases: () = databaseVM.fetchDatabases()
            
            _ = await (files, startup, schedules, backups, databases)
        }
        
        vm.updateBackups = {
            await backupVM.fetchBackups()
        }
    }
    
    private var panel: some View {
        TabView(selection: $store.lastTabPanel) {
            if let server = vm.server {
                Tab("Info", systemImage: "info.circle", value: .info) {
                    InfoTab(server)
                        .sheet($vm.sheetSettings) {
                            PanelSettingsParent(server)
                        }
                }
                
                Tab("Console", systemImage: "terminal", value: .console) {
                    ConsoleTab(server.id)
                }
                
                Tab("Files", systemImage: "folder", value: .files) {
                    FileTab(server.id)
                }
                
                Tab("Data", systemImage: "externaldrive.badge.icloud", value: .backup) {
                    DataTab(server)
                }
                
                Tab("Startup", systemImage: "play.circle", value: .startup) {
                    StartupView(server)
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    PanelView("")
        .environmentObject(ValueStore())
}
