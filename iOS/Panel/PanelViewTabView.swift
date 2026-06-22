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
                    .panelCodexChatToolbar()
                
            case .allocations:
                AllocationList(server)
                    .panelCodexChatToolbar()
                
            case .users:
                SubuserList()
                    .panelCodexChatToolbar()
                
            case .logs:
                LogList()
                    .panelCodexChatToolbar()
                
            case .subdomains:
                SubdomainList(server.allocation.map { [$0] } ?? [], limit: server.featureLimits.subdomains)
                    .panelCodexChatToolbar()
                
            case .console:
                ConsoleTab(server.id)
                    .panelCodexChatToolbar()
                
            case .files:
                FileTab(server.id)
                
            case .backup:
                BackupTab(server)
                    .panelCodexChatToolbar()

            case .schedules:
                ScheduleTab()
                    .panelCodexChatToolbar()

            case .databases:
                DatabaseTab(server)
                    .panelCodexChatToolbar()
                
            case .settings:
                ServerSettingsView(server)
                    .panelCodexChatToolbar()
                
            case .startup:
                StartupView(server)
                    .panelCodexChatToolbar()
                
            case .versionChanger:
                VersionChangerTab(server.uuid, showsDismissButton: false)
                    .environment(versionChangerVM)
                    .panelCodexChatToolbar()
                
            case .modInstaller:
                ModManagerTab(server.uuid, showsDismissButton: false)
                    .panelCodexChatToolbar()
                
            case .pluginInstaller:
                PluginManagerTab(server.uuid, showsDismissButton: false)
                    .panelCodexChatToolbar()
                
            case .modpackInstaller:
                ModpackInstallerTab(server.uuid)
                    .panelCodexChatToolbar()
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
