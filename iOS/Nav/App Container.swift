import ScrechKit
import SwiftData
import PteroNet

#if canImport(DeviceKit)
import DeviceKit
#endif

struct AppContainer: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(NavState.self) private var navState
    @State private var vm = ServerListVM()
    @State private var linking = DeepLinkVM()
    @State private var network = NetworkVM()
    
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
        .animation(.default, value: store.isApiKeyValid)
        .environment(vm)
        .environment(network)
        .preferredColorScheme(store.colorTheme.scheme)
#if canImport(AlertKit)
        .onChange(of: network.isNetworkSatisfied) { _, status in
            guard let status, status else {
                SystemAlert.networkError()
                return
            }
        }
#endif
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive {
                showBadge = false
            } else if newPhase == .active {
                delay(0.5) {
                    showBadge = true
                }
            }
        }
        .onOpenURL(perform: linking.handleDeepLink)
        .alert("Authentication with session", isPresented: $linking.alertAuth) {
            Button("Confirm") {
                auth()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to continue?")
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
