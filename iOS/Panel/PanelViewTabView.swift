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
                    .codexChatToolbar()
                
            case .allocations:
                AllocationList(server)
                    .codexChatToolbar()
                
            case .users:
                SubuserList()
                    .codexChatToolbar()
                
            case .logs:
                LogList()
                
            case .subdomains:
                SubdomainList(server.allocation.map { [$0] } ?? [], limit: server.featureLimits.subdomains)
                    .codexChatToolbar()
                
            case .console:
                ConsoleTab(server.id)
                
            case .files:
                FileTab(server.id)
                
            case .backup:
                BackupTab(server)
                    .codexChatToolbar()

            case .schedules:
                ScheduleTab()
                    .codexChatToolbar()

            case .databases:
                DatabaseTab(server)
                    .codexChatToolbar()
                
            case .settings:
                ServerSettingsView(server)
                    .codexChatToolbar()
                
            case .startup:
                StartupTab(server)
                    .codexChatToolbar()
                
            case .versionChanger:
                VersionChangerTab(server.uuid, showsDismissButton: false)
                    .environment(versionChangerVM)
                    .codexChatToolbar()
                
            case .modInstaller:
                ModManagerTab(server.uuid, showsDismissButton: false)
                    .codexChatToolbar()
                
            case .pluginInstaller:
                PluginManagerTab(server.uuid, showsDismissButton: false)
                    .codexChatToolbar()
                
            case .modpackInstaller:
                ModpackInstallerTab(server.uuid)
                    .codexChatToolbar()
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
