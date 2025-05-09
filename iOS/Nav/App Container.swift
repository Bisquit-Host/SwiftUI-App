import ScrechKit
import SwiftData
import PteroNet

#if canImport(DeviceKit)
import DeviceKit
#endif

struct AppContainer: View {
    @State private var vm = ServerListVM()
    @State private var linking = DeepLinkVM()
    @State private var network = NetworkVM()
    
    @EnvironmentObject private var store: ValueStore
    @Environment(NavState.self) private var nav
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(animation: .default) private var keys: [APIKey]
    
    @State private var showBadge = false
    
#if os(iOS)
    @State private var orientation = UIDevice.current.orientation
#endif
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
            if store.isApiKeyValid {
#if os(macOS)
                Home()
#else
                ServerList()
                    .withNavDestinations()
#endif
            } else {
                IntroParent()
                    .withNavDestinations()
            }
        }
        .animation(.default, value: store.isApiKeyValid)
        .environment(vm)
        .preferredColorScheme(store.colorTheme.scheme)
        .onOpenURL(perform: linking.handleDeepLink)
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
            if Device.current.hasDynamicIsland && showBadge && orientation.isPortrait, store.showDynamicIslandBadge {
                DynamicIslandBadge()
            }
        }
#endif
    }
    
    private func auth() {
        Keychain.save(linking.apiKey, forKey: "selectedApiKey")
        
        if !keys.contains(where: { $0.key == linking.apiKey }) {
            modelContext.insert(
                APIKey("Session", key: linking.apiKey)
            )
        }
        
        store.authSucced()
    }
}
