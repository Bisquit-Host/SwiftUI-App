import Foundation

struct PanelSidebarSection: Identifiable, Hashable {
    let key: Key
    let tabs: [Tabs]
    
    var id: Key { key }
    var title: String { key.title }
}

extension PanelSidebarSection {
    enum Key: String, Identifiable {
        case general, management, minecraft, configuration
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .general:
                String(localized: "General")
                    .uppercased(with: .current)
            case .management:
                String(localized: "Management")
                    .uppercased(with: .current)
            case .minecraft:
                String(localized: "Minecraft")
                    .uppercased(with: .current)
            case .configuration:
                String(localized: "Configuration")
                    .uppercased(with: .current)
            }
        }
    }
    
    static let all: [PanelSidebarSection] = [
        PanelSidebarSection(
            key: .general,
            tabs: [
                .info,
                .console,
                .settings,
                .logs
            ]
        ),
        PanelSidebarSection(
            key: .management,
            tabs: [
                .files,
                .databases,
                .backup,
                .allocations
            ]
        ),
        PanelSidebarSection(
            key: .minecraft,
            tabs: [
                .versionChanger,
                .pluginInstaller,
                .modInstaller,
                .modpackInstaller
            ]
        ),
        PanelSidebarSection(
            key: .configuration,
            tabs: [
                .schedules,
                .users,
                .startup,
                .subdomains
            ]
        )
    ]
}
