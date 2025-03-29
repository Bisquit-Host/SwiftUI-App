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
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
        self.backupVM = BackupVM(id)
        self.databaseVM = DatabaseVM(id)
        self.scheduleVM = ScheduleVM(id)
        self.startupVM = StartupVM(id)
        self.consoleVM = ConsoleVM(id)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        NavigationView {
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
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
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
        .alert(isPresented: $vm.alertNewFolder) {
            CustomDialog(
                title: "New Folder",
                content: "Enter a folder name",
                image: .init(content: "folder.badge.plus", tint: .blue, foreground: .white),
                button1: .init(content: "Create", tint: .blue, foreground: .white) { folder in
                    if !folder.isEmpty {
                        fileVM.createFolder(folder, at: fileVM.path)
                    }
                    
                    vm.alertNewFolder = false
                },
                button2: .init(content: "Cancel", tint: .red, foreground: .white) { _ in
                    vm.alertNewFolder = false
                },
                addsTextField: true,
                textFieldHint: "Me name folder"
            )
            .transition(.blurReplace.combined(with: .scale(0.8)))
        }
    }
    
    private func fetchData() {
        vm.fetchServerDetails()
        
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
        }
        
        vm.updateBackups = {
            backupVM.fetchBackups()
        }
    }
}

#Preview {
    PanelView("")
        .environmentObject(ValueStore())
}
