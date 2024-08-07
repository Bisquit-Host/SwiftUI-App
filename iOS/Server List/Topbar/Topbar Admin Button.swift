import SwiftUI

struct TopbarAdminButton: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    private let fetchServers: () -> Void
    
    init(_ fetchServers: @escaping () -> Void = {}) {
        self.fetchServers = fetchServers
    }
    
    var body: some View {
        if settings.adminMode {
            Button {
                settings.adminServerList.toggle()
                fetchServers()
            } label: {
                Image(systemName: settings.adminServerList ? "person.badge.shield.checkmark.fill" : "person.badge.shield.checkmark")
            }
        }
    }
}

#Preview {
    TopbarAdminButton()
        .environmentObject(SettingsStorage())
}
