import SwiftUI
import SwiftData
import PteroNet

struct AccountSettings: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var sheetKeyStorage = false
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            if keys.count > 0 {
                Button("Switch account", systemImage: "chevron.up.chevron.down") {
                    sheetKeyStorage = true
                }
                .sheet($sheetKeyStorage) {
                    CloudKeys($vm.apiKey) {
                        Task {
                            await vm.fetchServers(store.adminServerList)
                        }
                    }
                }
            }
            
            Button("Log out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                logout()
            }
            .foregroundStyle(.red)
        }
    }
    
    private func logout() {
        navState.clear()
        store.isApiKeyValid = false
        Keychain.delete(key: "selectedApiKey")
    }
}

#Preview {
    AccountSettings()
        .environment(ServerListVM())
        .environment(NavState())
        .environmentObject(ValueStore())
}
