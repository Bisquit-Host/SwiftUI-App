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
                Image(systemName: "person.badge.shield.checkmark")
                    .title(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 5)
                    .frame(width: 60, height: 60)
                    .background(settings.adminServerList ? .green : .orange, in: .rect(cornerRadius: 20))
            }
        }
    }
}

#Preview {
    TopbarAdminButton()
}
