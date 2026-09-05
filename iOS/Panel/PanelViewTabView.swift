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
                    .agentChatToolbar()
                
            case .allocations:
                AllocationList(server)
                    .agentChatToolbar()
                
            case .users:
                SubuserList()
                    .agentChatToolbar()
                
            case .logs:
                LogList()
                
            case .subdomains:
                SubdomainList(server.allocation.map { [$0] } ?? [], limit: server.featureLimits.subdomains)
                    .agentChatToolbar()
                
            case .console:
                ConsoleTab(server.id)
                
            case .files:
                FileTab(server.id)
                
            case .backup:
                BackupTab(server)
                    .agentChatToolbar()

            case .schedules:
                ScheduleTab()
                    .agentChatToolbar()

            case .databases:
                DatabaseTab(server)
                    .agentChatToolbar()
                
            case .settings:
                ServerSettingsView(server)
                    .agentChatToolbar()
                
            case .startup:
                StartupTab(server)
                    .agentChatToolbar()
                
            case .versionChanger:
                VersionChangerTab(server.uuid, showsDismissButton: false)
                    .environment(versionChangerVM)
                    .agentChatToolbar()
                
            case .modInstaller:
                ModManagerTab(server.uuid, showsDismissButton: false)
                    .agentChatToolbar()
                
            case .pluginInstaller:
                PluginManagerTab(server.uuid, showsDismissButton: false)
                    .agentChatToolbar()
                
            case .modpackInstaller:
                ModpackInstallerTab(server.uuid)
                    .agentChatToolbar()
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
