import ScrechKit
import SwiftData
import PteroNet

struct AppContainer: View {
    @State private var vm = ServerListVM()
    @State private var linking = DeepLinkVM()
    @State private var network = NetworkVM()
#if os(iOS) || os(visionOS)
    @State private var billingOAuth = OAuthVM()
    @State private var biometry = BiometryVM()
    @State private var confetti = ConfettiVM()
#endif
    @EnvironmentObject private var store: ValueStore
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
#if os(iOS) || os(visionOS)
        @Bindable var billingOAuth = billingOAuth
#endif
        HomeTabView()
            .animation(.default, value: store.isApiKeyValid)
            .environment(vm)
#if os(iOS) || os(visionOS)
            .environment(billingOAuth)
            .environment(biometry)
            .confettiOverlay()
            .environment(confetti)
            .sheet(isPresented: $billingOAuth.showTwoFASheet) {
                NavigationStack {
                    TwoFASheetView(
                        code: $billingOAuth.twoFACode,
                        isVerifying: $billingOAuth.isVerifyingTwoFA
                    ) {
                        await billingOAuth.verify2FA()
                    }
                    .padding()
                    .navigationTitle("Enter 2FA code")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
#endif
#if os(iOS)
            .statusBarHidden(store.hideStatusBar)
#endif
#if canImport(Appearance)
            .preferredColorScheme(store.appearance.scheme)
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
                Logger().info("🔗 Deeplink: \($0)")
                if $0.scheme == "bisq" {
                    linking.handleDeepLink($0)
                }
                
#if os(iOS) || os(visionOS)
                billingOAuth.handleCallback($0) {
                    store.updateAccessToken()
                }
#endif
            }
#if os(iOS)
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUniversalLinkActivity)
#endif
            .alert("Authentication with session", isPresented: $linking.alertAuth) {
                Button("Confirm", role: .confirmy, action: auth)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to continue?")
            }
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

#if os(iOS)
    private func handleUniversalLinkActivity(_ activity: NSUserActivity) {
        guard let url = activity.webpageURL else {
            Logger().error("🔗 Universal link missing URL")
            return
        }
        
        Logger().info("🔗 Universal link: \(url)")
        linking.handleUniversalLink(url)
    }
#endif
}
