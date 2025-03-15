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
    @State private var subdomainVM: SubdomainVM
    
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
        self.subdomainVM = SubdomainVM(id)
    }
    
    @State private var sheetSettings = false
    @State private var alertNewFolder = false
    
    var body: some View {
        TabView(selection: $store.lastTabPanel) {
            if let server = vm.server {
                InfoTab(server)
                    .tab(.info)
                    .sheet($sheetSettings) {
                        PanelSettingsParent(server)
                    }
                
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
                
                SubdomainList()
                    .environment(subdomainVM)
                    .tab(.subdomain)
            }
        }
        .sidebarAdaptableTabView()
        .navigationBarBackButtonHidden()
        .environment(vm)
        .task {
            fetchData()
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .foregroundStyle(.primary)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                if store.lastTabPanel == .files {
                    Button {
                        alertNewFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .footnote(.bold)
                            .frame(width: 35, height: 35)
                            .background(.ultraThinMaterial, in: .circle)
                    }
                    .foregroundStyle(.primary)
                    .padding(.trailing, -10)
                }
                
                Button {
                    sheetSettings = true
                } label: {
                    Image(systemName: "ellipsis")
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .foregroundStyle(.primary)
                .keyboardShortcut("S")
                .animation(.default, value: store.lastTabPanel)
            }
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
        .alert(isPresented: $alertNewFolder) {
            CustomDialog(
                title: "New Folder",
                content: "Enter a folder name",
                image: .init(content: "folder.badge.plus", tint: .blue, foreground: .white),
                button1: .init(content: "Create", tint: .blue, foreground: .white) { folder in
                    if !folder.isEmpty {
                        fileVM.createFolder(folder, at: fileVM.path)
                    }
                    
                    alertNewFolder = false
                },
                button2: .init(content: "Cancel", tint: .red, foreground: .white) { _ in
                    alertNewFolder = false
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
            
            Task {
                await subdomainVM.fetchSubdomains()
            }
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
