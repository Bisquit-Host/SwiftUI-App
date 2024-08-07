import ScrechKit

struct ServerListTopbar: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: SettingsStorage
    
    @Binding private var filterBySuspended: Bool
    
    init(_ filterBySuspended: Binding<Bool>) {
        _filterBySuspended = filterBySuspended
    }
    
    var body: some View {
        TopbarAdminButton {
            vm.fetchServers(settings.adminServerList)
        }
        .padding(.horizontal, 5)
    }
}

#warning("iOS 18")
//#Preview {
//    @Previewable @State var filterBySuspended = false
//    
//    ServerListTopbar($filterBySuspended)
//        .environment(ServerListVM())
//        .environmentObject(SettingsStorage())
//}
