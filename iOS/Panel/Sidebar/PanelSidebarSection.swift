import SwiftUI

struct PanelSidebarSection: Identifiable, Hashable {
    let key: Key
    let tabs: [Tabs]
    
    var id: Key { key }
    var title: LocalizedStringKey { key.title }
}

extension PanelSidebarSection {
    enum Key: String, Identifiable {
        case general, management, minecraft, configuration
        
        var id: String { rawValue }
        
        var title: LocalizedStringKey {
            switch self {
            case .general: "General"
            case .management: "Management"
            case .minecraft: "Minecraft"
            case .configuration: "Configuration"
            }
        }
    }
    
    static let all = [
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
                .backup,
                .databases,
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
