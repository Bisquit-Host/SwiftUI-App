import SwiftUI

#if canImport(DeviceKit)
import DeviceKit
#endif

struct AppContainer: View {
    @State private var vm = ServerListVM()
    @EnvironmentObject private var store: ValueStore
    @Environment(NavState.self) private var navState
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showBadge = false
    
#if os(iOS)
    @State private var orientation = UIDevice.current.orientation
#endif
    
    var body: some View {
        @Bindable var navState = navState
        
        NavigationStack(path: $navState.path) {
            if store.isApiKeyValid {
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
        .preferredColorScheme(store.colorTheme.scheme)
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
        .statusBarHidden(store.hideStatusBar)
        .detectOrientation($orientation)
        .overlay(alignment: .top) {
            if Device.current.hasDynamicIsland && showBadge && orientation.isPortrait {
                DynamicIslandBadge()
            }
        }
#endif
    }
}
