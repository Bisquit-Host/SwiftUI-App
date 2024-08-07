import SwiftUI

#if canImport(DeviceKit)
import DeviceKit
#endif

struct AppContainer: View {
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showBadge = false
    @State private var vm = ServerListVM()
    
    var body: some View {
        @Bindable var binding = navState
        
        NavigationStack(path: $binding.path) {
            if settings.isApiKeyValid {
#if !os(watchOS)
                AuthView()
                    .withNavDestinations()
#else
                ServerList()
                    .withNavDestinations()
#endif
            } else {
                Intro()
                    .withNavDestinations()
            }
        }
        .environment(vm)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive {
                showBadge = false
            } else if newPhase == .active {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showBadge = true
                }
            }
        }
#if os(iOS)
        .overlay(alignment: .top) {
            let device = Device.current
            
            if device.hasDynamicIsland && showBadge {
                DynamicIslandBadge()
            }
        }
#endif
    }
}
