import ScrechKit

struct PanelViewTabView: View {
    @Environment(PanelVM.self) private var vm
    
    let selectedTab: Tabs
    
    var body: some View {
        if let server = vm.server {
            switch selectedTab {
            case .info:
                PanelInfoTabView(server)
                
            case .console:
                PanelConsoleTabView(server.id)
                
            case .files:
                PanelFilesTabView(server.id)
                
            case .backup:
                PanelDataTabView(server)
                
            case .startup:
                PanelStartupTabView(server)
                
            case .subdomain:
                PanelSubdomainsTabView(server)
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
