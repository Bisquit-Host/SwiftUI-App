import SwiftUI

struct TopbarAdminButton: View {
    @EnvironmentObject private var settings: ValueStorage
    
    private let fetchServers: () -> Void
    
    init(_ fetchServers: @escaping () -> Void = {}) {
        self.fetchServers = fetchServers
    }
    
    private var icon: String {
        if settings.adminServerList {
            "person.badge.shield.checkmark.fill"
        } else {
            "person.badge.shield.checkmark"
        }
    }
    
    var body: some View {
        if settings.devMode {
            Button {
                settings.adminServerList.toggle()
                fetchServers()
            } label: {
                Image(systemName: icon)
            }
        }
    }
}

#Preview {
    TopbarAdminButton()
        .environmentObject(ValueStorage())
}
