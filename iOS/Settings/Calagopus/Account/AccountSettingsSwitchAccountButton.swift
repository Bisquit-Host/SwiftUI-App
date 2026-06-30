import SwiftUI
import SwiftData

struct AccountSettingsSwitchAccountButton: View {
    @Environment(ServerListVM.self) private var vm
    @Query(animation: .default) private var keys: [APIKey]
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetKeyStorage = false
    
    var body: some View {
        @Bindable var vm = vm
        
        if keys.count > 0 {
            GlassyActionCard("Switch account", icon: "person.crop.circle", actionIcon: "chevron.up.chevron.down", tint: .indigo) {
                sheetKeyStorage = true
            }
            .sheet($sheetKeyStorage) {
                CloudKeysParent($vm.apiKey) {
                    await vm.fetchServers(store.adminServerList)
                }
            }
        }
    }
}

#Preview {
    AccountSettingsSwitchAccountButton()
        .darkSchemePreferred()
}
