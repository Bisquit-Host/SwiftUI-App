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
            if System.isIpad {
                PanelViewTabView()
            } else {
                NavigationView {
                    PanelViewTabView()
                }
            }
        }
        .navigationTitle(vm.server?.name ?? "")
        .navigationSubtitle(vm.server?.description ?? "")
        .panelToolbar()
        .environment(vm)
        .environmentObject(fileVM)
        .environment(consoleVM)
        .environment(backupVM)
        .environment(databaseVM)
        .environment(scheduleVM)
        .environment(startupVM)
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
        .alert("New Folder", isPresented: $vm.alertNewFolder) {
            TextField("Enter a folder name", text: $fileVM.newFolderName)
            
            Button("Create", role: .confirm) {
                createFolder()
            }
            
            Button("Cancel", role: .cancel) {
                fileVM.newFolderName = ""
            }
        }
    }
    
    private func createFolder() {
        if !fileVM.newFolderName.isEmpty {
            Task {
                await fileVM.createFolder(fileVM.newFolderName, at: fileVM.path)
            }
            
            fileVM.newFolderName = ""
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
        
        vm.updateBackups = { await backupVM.fetchBackups() }
    }
}

#Preview {
    NavigationStack {
        PanelView("")
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
