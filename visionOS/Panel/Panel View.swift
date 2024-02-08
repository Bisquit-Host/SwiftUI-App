import ScrechKit

struct PanelView: View {
    @StateObject var ornament = OrnamentProperty()
    
    private var vm: PanelVM
    private var backupVM: BackupVM
    private var dbVM: DatabaseVM
    private var userVM: UsersVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = PanelVM(id)
        self.backupVM = BackupVM(id)
        self.dbVM = DatabaseVM(id)
        self.userVM = UsersVM(id)
    }
    
    @AppStorage("tab_panel") private var tabPanel: Tab = .info
    @AppStorage("show_power_buttons") private var showPowerButtons = true
    @AppStorage("show_info") private var showInfo = true
    
    var body: some View {
        VStack {
            if let server = vm.server {
                TabView(selection: $tabPanel) {
                    InfoTab(server)
                        .tag(Tab.info)
                        .tabItem {
                            Label("Info", systemImage: "info.circle")
                        }
                    
                    Console(server.id)
                        .environment(vm)
                        .tag(Tab.console)
                        .tabItem {
                            Label("Console", systemImage: "apple.terminal")
                        }
                    
                    UserList()
                        .environment(userVM)
                        .tag(Tab.users)
                        .tabItem {
                            Label("Users", systemImage: "person.3")
                        }
                    
                    BackupList(server)
                        .environment(backupVM)
                        .tag(Tab.backups)
                        .tabItem {
                            Label("Backups", systemImage: "archivebox")
                        }
                    
                    DatabaseList(server.featureLimits.databases)
                        .environment(dbVM)
                        .tag(Tab.databases)
                        .tabItem {
                            Label("Databases", systemImage: "externaldrive.badge.icloud")
                        }
                }
            }
        }
        .navigationTitle(vm.server?.name ?? "Error")
        .task {
            vm.fetchServerDetails()
            backupVM.fetchBackups()
            dbVM.fetchDatabases()
            userVM.fetchUsers()
            
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
                
                Button {
                    withAnimation {
                        showInfo.toggle()
                    }
                } label: {
                    Text(showInfo ? "Hide info" : "Show info")
                }
            } label: {
                Image(systemName: "gear")
            }
        }
        .ornament(attachmentAnchor: .scene(.trailing)) {
            if showInfo {
                if let server = vm.server {
                    PanelOrnamentInfo(server, showCustomizeButton: true)
                        .environmentObject(ornament)
                        .padding(.leading, 150)
                }
            }
        }
        .ornament(attachmentAnchor: .scene(.top)) {
            if showPowerButtons {
                HStack {
                    Button {
                        
                    } label: {
                        Label("Start", systemImage: "play")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("Stop", systemImage: "stop")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("Restart", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Capsule(.primary)
                        .frame(width: 4, height: 32)
                    
                    Menu {
                        Button {
                            
                        } label: {
                            Label("Kill", systemImage: "power")
                        }
                    } label: {
                        Label("Kill", systemImage: "power")
                    }
                }
                .padding(.bottom, 90)
            }
        }
    }
}

#Preview {
    NavigationView {
        PanelView("")
    }
    .navigationViewStyle(.stack)
}
