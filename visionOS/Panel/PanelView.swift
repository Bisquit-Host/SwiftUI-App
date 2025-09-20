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
        
        vm = PanelVM(id)
        fileVM = FileTabVM(id)
        backupVM = BackupVM(id)
        dbVM = DatabaseVM(id)
        scheduleVM = ScheduleVM(id)
        userVM = UsersVM(id)
        subdomainVM = SubdomainVM(id)
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
                    Tab("Info", systemImage: "info.circle", value: PanelTab.info) {
                        InfoTab(server)
                            .environment(vm)
                    }
                    
                    Tab("Console", systemImage: "apple.terminal", value: PanelTab.console) {
                        Console(id)
                            .environment(vm)
                    }
                    
                    Tab("Files", systemImage: "folder", value: PanelTab.files) {
                        FileList(id)
                            .environmentObject(fileVM)
                    }
                    
                    Tab("Backups", systemImage: "archivebox", value: PanelTab.backups) {
                        List {
                            BackupList(server)
                        }
                        .environment(backupVM)
                    }
                    
                    Tab("Databases", systemImage: "externaldrive.badge.icloud", value: PanelTab.databases) {
                        List {
                            DatabaseList(server.featureLimits.databases)
                        }
                        .environment(dbVM)
                    }
                    
                    Tab("Schedules", systemImage: "calendar", value: PanelTab.schedules) {
                        List {
                            ScheduleList()
                        }
                        .environment(scheduleVM)
                    }
                    
                    Tab("Users", systemImage: "person.3", value: PanelTab.users) {
                        UserList()
                            .environment(userVM)
                    }
                    
                    Tab("Subdomains", systemImage: "globe", value: PanelTab.subdomains) {
                        SubdomainList(allocations)
                            .environment(subdomainVM)
                    }
                }
            }
        }
        .navigationTitle(vm.server?.name ?? "")
        .task {
            await vm.fetchServerDetails()
            
            if let data = await vm.consoleDetails() {
                vm.connectWebSocket(data)
            }
            
            if !System.lowPowerMode {
                async let files: () = fileVM.fetchFiles()
                async let users: () = userVM.fetchUsers(true)
                async let subdomains: () = subdomainVM.fetchSubdomains()
                async let backups: () = backupVM.fetchBackups()
                async let databases: () = dbVM.fetchDatabases()
                
                _ = await (
                    files, users, subdomains, backups, databases
                )
            }
            
            vm.updateBackups = {
                await backupVM.fetchBackups()
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
            Task {
                if let data = await vm.consoleDetails() {
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
            PowerSwitch()
                .padding(.bottom, 100)
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
    NavigationStack {
        PanelView(PreviewProp.serverAttributes)
    }
    .navigationViewStyle(.stack)
}
