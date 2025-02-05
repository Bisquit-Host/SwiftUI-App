import ScrechKit

struct PanelView: View {
    @StateObject private var ornament = OrnamentProperty()
    private var vm: PanelVM
    private var fileVM: FileTabVM
    private var backupVM: BackupVM
    private var dbVM: DatabaseVM
    private var scheduleVM: ScheduleVM
    private var userVM: UsersVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
        self.backupVM = BackupVM(id)
        self.dbVM = DatabaseVM(id)
        self.scheduleVM = ScheduleVM(id)
        self.userVM = UsersVM(id)
    }
    
    @AppStorage("show_info") private var showInfo = true
    @AppStorage("tab_panel") private var tabPanel: Tab = .info
    @AppStorage("show_power_buttons") private var showPowerButtons = true
    
    var body: some View {
        VStack {
            if let server = vm.server {
                TabView(selection: $tabPanel) {
                    InfoTab(server)
                        .tag(Tab.info)
                        .tabItem {
                            Label("Info", systemImage: "info.circle")
                        }
                    
                    Console(id)
                        .environment(vm)
                        .tag(Tab.console)
                        .tabItem {
                            Label("Console", systemImage: "apple.terminal")
                        }
                    
                    FileList(id)
                        .environmentObject(fileVM)
                        .tag(Tab.files)
                        .tabItem {
                            Label("Files", systemImage: "folder")
                        }
                    
                    List {
                        BackupList(server)
                    }
                    .environment(backupVM)
                    .tag(Tab.backups)
                    .tabItem {
                        Label("Backups", systemImage: "archivebox")
                    }
                    
                    List {
                        DatabaseList(server.featureLimits.databases)
                    }
                    .environment(dbVM)
                    .tag(Tab.databases)
                    .tabItem {
                        Label("Databases", systemImage: "externaldrive.badge.icloud")
                    }
                    
                    List {
                        ScheduleList()
                    }
                    .environment(scheduleVM)
                    .tag(Tab.schedules)
                    .tabItem {
                        Label("Schedules", systemImage: "calendar")
                    }
                    
                    UserList()
                        .environment(userVM)
                        .tag(Tab.users)
                        .tabItem {
                            Label("Users", systemImage: "person.3")
                        }
                }
            }
        }
        .navigationTitle(vm.server?.name ?? "")
        .task {
            vm.fetchServerDetails()
            
            if !System.lowPowerMode {
                backupVM.fetchBackups()
                dbVM.fetchDatabases()
                userVM.fetchUsers()
                fileVM.fetchFiles()
            }
            
            vm.updateBackups = {
                delay {
                    backupVM.fetchBackups()
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
#warning("???")
#if DEBUG
                NavigationLink("Temp dir (debug)") {
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
        PanelView("")
    }
    .navigationViewStyle(.stack)
}
