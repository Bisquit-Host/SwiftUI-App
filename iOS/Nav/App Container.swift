import SwiftUI
import SwiftData
import PteroNet

#if canImport(DeviceKit)
import DeviceKit
#endif

struct AppContainer: View {
    @State private var vm = ServerListVM()
#if !os(macOS)
    @State private var linking = DeepLinkVM()
#endif
    @EnvironmentObject private var store: ValueStore
    @Environment(NavState.self) private var navState
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var showBadge = false
    
#if os(iOS)
    @State private var orientation = UIDevice.current.orientation
#endif
    
    var body: some View {
        @Bindable var navState = navState
        
        NavigationStack(path: $navState.path) {
            if store.isApiKeyValid {
#if os(macOS)
                Home()
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
#if !os(macOS)
        .onOpenURL(perform: linking.handleDeepLink)
        //        .onOpenURL { url in
        //            linking.handleDeepLink(url)
        //        }
        .alert("Authentication with session", isPresented: $linking.alertAuth) {
            Button("Confirm") {
                auth()
            }
            
            Button("Cancel", role: .cancel) {
                auth()
            }
        } message: {
            Text("Are you sure you want to continue?")
        }
#endif
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
    
    private func auth() {
        Keychain.save(
            key: "selectedApiKey",
            value: linking.session
        )
        
        if !keys.contains(where: { $0.key == linking.session }) {
            modelContext.insert(APIKey("Session", key: linking.session))
        }
        
        store.authSucced()
    }
}
