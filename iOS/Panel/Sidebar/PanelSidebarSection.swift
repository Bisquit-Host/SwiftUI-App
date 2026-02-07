import Foundation

struct PanelSidebarSection: Identifiable, Hashable {
    let title: String
    let tabs: [Tabs]
    
    var id: String { title }
}

extension PanelSidebarSection {
    static let all: [PanelSidebarSection] = [
        PanelSidebarSection(
            title: "GENERAL",
            tabs: [
                .info,
                .console,
                .settings,
                .logs
            ]
        ),
        PanelSidebarSection(
            title: "MANAGEMENT",
            tabs: [
                .files,
                .databases,
                .backup,
                .allocations
            ]
        ),
        PanelSidebarSection(
            title: "MINECRAFT",
            tabs: [
                .versionChanger,
                .pluginInstaller,
                .modInstaller,
                .modpackInstaller
            ]
        ),
        PanelSidebarSection(
            title: "CONFIGURATION",
            tabs: [
                .schedules,
                .users,
                .startup,
                .subdomains
            ]
        )
    ]
}
