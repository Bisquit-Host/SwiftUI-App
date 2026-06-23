import SwiftUI
import Calagopus

struct PanelView: View {
    @StateObject private var ornament = OrnamentValueStore()
    @EnvironmentObject private var store: ValueStore
    
    private var vm: PanelVM
    private var fileVM: FileTabVM
    private var backupVM: BackupVM
    private var dbVM: DatabaseVM
    private var scheduleVM: ScheduleVM
    private var userVM: SubuserVM
    private var subdomainVM: SubdomainVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        
        vm = PanelVM(id)
        fileVM = FileTabVM(id)
        backupVM = BackupVM(id)
        dbVM = DatabaseVM(id)
        scheduleVM = ScheduleVM(id)
        userVM = SubuserVM(id)
        subdomainVM = SubdomainVM(id)
    }
    
    var body: some View {
        VStack {
            if let server = vm.server {
                TabView(selection: $store.panelTab) {
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
                    
                    if server.featureLimits.subdomains != nil {
                        Tab("Subdomains", systemImage: "globe", value: PanelTab.subdomains) {
                            SubdomainList(server.allocation.map { [$0] } ?? [], limit: server.featureLimits.subdomains)
                                .environment(subdomainVM)
                        }
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
                async let backups: () = backupVM.fetchBackups()
                async let databases: () = dbVM.fetchDatabases()
                
                if vm.server?.featureLimits.subdomains != nil {
                    async let subdomains: () = subdomainVM.fetchSubdomains()
                    _ = await (files, users, subdomains, backups, databases)
                } else {
                    _ = await (files, users, backups, databases)
                }
            }
            
            vm.updateBackups = { await backupVM.fetchBackups() }
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
        .toolbar {
            Menu {
                Button {
                    withAnimation {
                        store.showPowerButtons.toggle()
                    }
                } label: {
                    Text(store.showPowerButtons ? "Hide power buttons" : "Show power buttons")
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
        PanelView(PreviewProp.serverAttributes.id)
    }
    .navigationViewStyle(.stack)
    .environmentObject(ValueStore())
}
