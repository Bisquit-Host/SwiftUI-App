import SwiftUI

struct PanelTabNavigationSheet: View {
    @Binding var selectedTab: PanelTab
    @Environment(\.dismiss) private var dismiss
    
    private let availableTabs: [PanelTab] = [.console, .files, .backups, .users, .logs, .databases, .allocations, .startup, .subdomains]
    
    var body: some View {
        List(availableTabs) { tab in
            Button(tab.name, systemImage: systemImage(for: tab)) {
                dismiss()
                selectedTab = tab
            }
            .disabled(selectedTab == tab)
        }
        .navigationTitle("Tabs")
    }
    
    private func systemImage(for tab: PanelTab) -> String {
        switch tab {
        case .info: "info.circle"
        case .console: "terminal"
        case .files: "folder"
        case .backups: "externaldrive.badge.icloud"
        case .settings: "gearshape"
        case .startup: "play.circle"
        case .users: "person.2"
        case .schedules: "calendar.badge.clock"
        case .databases: "server.rack"
        case .allocations: "link"
        case .logs: "list.bullet.rectangle"
        case .subdomains: "globe"
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: PanelTab = .console
    
    PanelTabNavigationSheet(selectedTab: $selectedTab)
        .darkSchemePreferred()
}
