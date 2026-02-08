import ScrechKit

struct PanelViewTabView: View {
    @Environment(PanelVM.self) private var vm
    @Environment(VersionChangerVM.self) private var versionChangerVM
    
    let selectedTab: Tabs
    
    var body: some View {
        if let server = vm.server {
            switch selectedTab {
            case .info:
                InfoTab(server)
                
            case .allocations:
                AllocationList(server, showsDismissButton: false)
                
            case .users:
                UserList(showsDismissButton: false)
                
            case .logs:
                LogList(showsDismissButton: false)
                
            case .subdomains:
                let allocations = server.relationships.allocations.data.map(\.attributes)
                SubdomainList(allocations, showsDismissButton: false)
                
            case .console:
                ConsoleTab(server.id)
                
            case .files:
                FileTab(server.id)
                
            case .backup:
                BackupTab(server)

            case .schedules:
                ScheduleTab()

            case .databases:
                DatabaseTab(server)
                
            case .settings:
                ServerSettingsView(server)
                
            case .startup:
                StartupView(server)
                
            case .versionChanger:
                VersionChangerSheet(server.uuid, showsDismissButton: false)
                    .environment(versionChangerVM)
                
            case .modInstaller:
                ModManagerSheet(server.uuid, showsDismissButton: false)
                
            case .pluginInstaller:
                PluginManagerSheet(server.uuid, showsDismissButton: false)
                
            case .modpackInstaller:
                ModpackInstallerSheet(server.uuid, showsDismissButton: false)
            }
        } else {
            ContentUnavailableView("Loading server", systemImage: "server.rack")
        }
    }
}

#Preview {
    PanelViewTabView(selectedTab: .info)
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environment(ConsoleVM(""))
        .environmentObject(FileTabVM(""))
        .environmentObject(ValueStore())
}
