import ScrechKit

struct ServerListTopbar: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    @Binding private var filterBySuspended: Bool
    
    init(_ filterBySuspended: Binding<Bool>) {
        _filterBySuspended = filterBySuspended
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ServerListFilter($filterBySuspended)
                .environment(vm)
            
            TopbarAdminButton {
                vm.fetchServers(settings.adminServerList)
            }
            
            TopbarGridButton()
        }
        .padding(.horizontal, 5)
    }
}

#Preview {
    ServerListTopbar(.constant(false))
        .environment(ServerListVM())
        .environmentObject(SettingsStorage())
}
