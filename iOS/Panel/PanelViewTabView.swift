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
                AllocationList(server)
                
            case .users:
                SubuserList()
                
            case .logs:
                LogList()
                
            case .subdomains:
                SubdomainList(server.allocation.map { [$0] } ?? [], limit: server.featureLimits.subdomains)
                
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
                VersionChangerTab(server.uuid, showsDismissButton: false)
                    .environment(versionChangerVM)
                
            case .modInstaller:
                ModManagerTab(server.uuid, showsDismissButton: false)
                
            case .pluginInstaller:
                PluginManagerTab(server.uuid, showsDismissButton: false)
                
            case .modpackInstaller:
                ModpackInstallerTab(server.uuid)
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
