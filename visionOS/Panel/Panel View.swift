import ScrechKit
import PteroNet

struct PanelView: View {
    @StateObject private var ornament = OrnamentProperty()
    private var vm: PanelVM
    private var fileVM: FileTabVM
    private var backupVM: BackupVM
    private var dbVM: DatabaseVM
    private var scheduleVM: ScheduleVM
    private var userVM: UsersVM
    private var subdomainVM: SubdomainVM
    
    private let server: ServerAttributes
    private let id: String
    
    init(_ server: ServerAttributes) {
        self.id = server.id
        self.server = server
        
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
        self.backupVM = BackupVM(id)
        self.dbVM = DatabaseVM(id)
        self.scheduleVM = ScheduleVM(id)
        self.userVM = UsersVM(id)
        self.subdomainVM = SubdomainVM(id)
    }
    
    @AppStorage("show_info") private var showInfo = true
    @AppStorage("tab_panel") private var tabPanel: PanelTab = .info
    @AppStorage("show_power_buttons") private var showPowerButtons = true
    
    private var allocations: [AllocationAttributes] {
        server.relationships.allocations.data.map(\.attributes)
    }
    
    var body: some View {
        VStack {
            if let server = vm.server {
                TabView(selection: $tabPanel) {
                    InfoTab(server)
                        .environment(vm)
                        .tag(PanelTab.info)
                        .tabItem {
                            Label("Info", systemImage: "info.circle")
                        }
                    
                    Console(id)
                        .environment(vm)
                        .tag(PanelTab.console)
                        .tabItem {
                            Label("Console", systemImage: "apple.terminal")
                        }
                    
                    FileList(id)
                        .environmentObject(fileVM)
                        .tag(PanelTab.files)
                        .tabItem {
                            Label("Files", systemImage: "folder")
                        }
                    
                    List {
                        BackupList(server)
                    }
                    .environment(backupVM)
                    .tag(PanelTab.backups)
                    .tabItem {
                        Label("Backups", systemImage: "archivebox")
                    }
                    
                    List {
                        DatabaseList(server.featureLimits.databases)
                    }
                    .environment(dbVM)
                    .tag(PanelTab.databases)
                    .tabItem {
                        Label("Databases", systemImage: "externaldrive.badge.icloud")
                    }
                    
                    List {
                        ScheduleList()
                    }
                    .environment(scheduleVM)
                    .tag(PanelTab.schedules)
                    .tabItem {
                        Label("Schedules", systemImage: "calendar")
                    }
                    
                    UserList()
                        .environment(userVM)
                        .tag(PanelTab.users)
                        .tabItem {
                            Label("Users", systemImage: "person.3")
                        }
                    
                    SubdomainList(allocations)
                        .environment(subdomainVM)
                        .tag(PanelTab.subdomains)
                        .tabItem {
                            Label("Subdomains", systemImage: "globe")
                        }
                }
            }
        }
        .navigationTitle(vm.server?.name ?? "")
        .task {
            await vm.fetchServerDetails()
            
            if !System.lowPowerMode {
                fileVM.fetchFiles()
                
                Task {
                    await userVM.fetchUsers(true)
                    await subdomainVM.fetchSubdomains()
                    await backupVM.fetchBackups()
                    await dbVM.fetchDatabases()
                }
            }
            
            vm.updateBackups = {
                Task {
                    await backupVM.fetchBackups()
                }
            }
            
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
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
        .toolbar {
            Menu {
                Button {
                    withAnimation {
                        showPowerButtons.toggle()
                    }
                } label: {
                    Text(showPowerButtons ? "Hide power buttons" : "Show power buttons")
                }
#if DEBUG
                NavigationLink("Temp dir contents (debug)") {
                    TempDir()
                }
#endif
                //                Button {
                //                    withAnimation {
                //                        showInfo.toggle()
                //                    }
                //                } label: {
                //                    Text(showInfo ? "Hide info" : "Show info")
                //                }
            } label: {
                Image(systemName: "gear")
            }
        }
        //        .ornament(attachmentAnchor: .scene(.trailing)) {
        //            if showInfo {
        //                if let server = vm.server {
        //                    PanelOrnamentInfo(server, showCustomizeButton: true)
        //                        .environmentObject(ornament)
        //                        .padding(.leading, 150)
        //                }
        //            }
        //        }
        .ornament(attachmentAnchor: .scene(.top)) {
            PanelOrnamentPower(showPowerButtons)
                .environment(vm)
        }
#warning("Finish ornament")
        //        .ornament(attachmentAnchor: .scene(.trailing)) {
        //            if let server = vm.server {
        //                PanelOrnamentInfo(server, showCustomizeButton: true)
        //                    .environmentObject(ornament)
        //            }
        //        }
    }
}

#Preview {
    NavigationView {
        PanelView(PreviewProp.serverAttributes)
    }
    .navigationViewStyle(.stack)
}
