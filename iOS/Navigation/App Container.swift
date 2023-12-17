import SwiftUI

struct AppContainer: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
    @State private var vm = ServerListVM()
    
    var body: some View {
        @Bindable var binding = navState
        
        NavigationStack(path: $binding.path) {
            if settings.isApiKeyValid {
                ServerList()
                    .withNavDestinations()
            } else {
                Intro()
                    .withNavDestinations()
            }
        }
        .environment(vm)
    }
}
