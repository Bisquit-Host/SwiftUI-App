import ScrechKit
import SwiftData
import PteroNet

struct AppContainer: View {
    @State private var vm = ServerListVM()
    @State private var linking = DeepLinkVM()
    @State private var network = NetworkVM()
    @State private var securityTasks = SecurityTasks()
#if os(iOS)
    @State private var billingOAuth = OAuthVM()
#endif
    @EnvironmentObject private var store: ValueStore
    @Environment(NavState.self) private var nav
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
        @Bindable var nav = nav
        
        NavigationStack(path: $nav.path) {
#if os(iOS)
            if store.testBilling {
                if (store.accessToken?.isEmpty ?? true) {
                    BillingLogin()
                        .withNavDestinations()
                } else {
                    BillingDashboard()
                        .withNavDestinations()
                }
            } else {
                if store.isApiKeyValid {
                    ServerList()
                        .withNavDestinations()
                } else {
                    StartPage()
                        .withNavDestinations()
                }
            }
#else
            if store.isApiKeyValid {
                ServerList()
                    .withNavDestinations()
            } else {
                StartPage()
                    .withNavDestinations()
            }
#endif
        }
        .animation(.default, value: store.isApiKeyValid)
        .environment(vm)
        .environment(securityTasks)
#if os(iOS)
        .environment(billingOAuth)
#endif
#if canImport(Appearance)
        .preferredColorScheme(store.appearance.scheme)
#endif
        .onFirstAppear {
            await securityTasks.startCheck()
            network.observeStatus()
        }
#if os(iOS) || os(visionOS)
        .appStoreOverlay($securityTasks.alertUpdate, id: 1639409934)
#elseif os(macOS)
        
#endif
#if canImport(AlertKit)
        .onChange(of: network.isNetworkSatisfied) { _, status in
            guard let status, status else {
                SystemAlert.networkError()
                return
            }
        }
#endif
        .onOpenURL {
            print("🔗 Depplink:", $0)
#if os(iOS)
            linking.handleDeepLink($0)
            billingOAuth.handleCallback($0)
#endif
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
