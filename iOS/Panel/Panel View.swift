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
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .environment(vm)
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
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
        }
        .alert(isPresented: $vm.alertNewFolder) {
            CustomDialog(
                title: "New Folder",
                content: "Enter a folder name",
                image: .init(content: "folder.badge.plus", foreground: .white),
                button1: .init(content: "Create", foreground: .white) { folder in
                    if !folder.isEmpty {
                        fileVM.createFolder(folder, at: fileVM.path)
                    }
                    
                    vm.alertNewFolder = false
                },
                button2: .init(content: "Cancel", foreground: .red) { _ in
                    vm.alertNewFolder = false
                },
                addsTextField: true,
                textFieldHint: "Me name folder"
            )
            .transition(.blurReplace.combined(with: .scale(0.8)))
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
            
            Task {
                await startupVM.fetchStartupVariables()
                await scheduleVM.fetchSchedules()
                await backupVM.fetchBackups()
                await databaseVM.fetchDatabases()
            }
        }
        
        vm.updateBackups = {
            Task {
                await backupVM.fetchBackups()
            }
        }
    }
    
    private var panel: some View {
        TabView(selection: $store.lastTabPanel) {
            if let server = vm.server {
                InfoTab(server)
                    .tab(.info)
                    .sheet($vm.sheetSettings) {
                        PanelSettingsParent(server)
                    }
                
                ConsoleTab(id)
                    .tab(.console)
                
                FileTab(id)
                    .tab(.files)
                
                DataTab(server)
                    .tab(.backup)
                
                StartupView(server)
                    .tab(.startup)
            }
        }
        .panelToolbar()
        .environment(consoleVM)
        .environmentObject(fileVM)
        .environment(backupVM)
        .environment(databaseVM)
        .environment(scheduleVM)
        .environment(startupVM)
    }
}

#Preview {
    PanelView("")
        .environmentObject(ValueStore())
}
