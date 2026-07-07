import ScrechKit
import OSLog

struct AppContainer: View {
    @State private var vm = ServerListVM()
    @State private var network = NetworkVM()
#if os(iOS) || os(visionOS)
    @State private var billingOAuth = OAuthVM()
    @State private var biometry = BiometryVM()
    @State private var confetti = ConfettiVM()
#endif
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
#if os(iOS) || os(visionOS)
        @Bindable var billingOAuth = billingOAuth
#endif
        Group {
#if os(iOS)
            HomeView()
#else
            HomeTabView()
#endif
        }
            .environment(vm)
#if os(iOS) || os(visionOS)
            .environment(billingOAuth)
            .environment(biometry)
            .confettiOverlay()
            .environment(confetti)
            .sheet($billingOAuth.showTwoFASheet) {
                NavigationStack {
                    Login2FASheet(code: $billingOAuth.twoFACode, isVerifying: $billingOAuth.isVerifyingTwoFA) {
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
#if os(iOS) || os(visionOS)
                billingOAuth.handleCallback($0) {
                    store.updateAccessToken()
                }
#endif
            }
#if os(iOS)
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUniversalLinkActivity)
#endif
    }

#if os(iOS)
    private func handleUniversalLinkActivity(_ activity: NSUserActivity) {
        guard let url = activity.webpageURL else {
            Logger().error("🔗 Universal link missing URL")
            return
        }
        
        Logger().info("🔗 Universal link: \(url)")
        billingOAuth.handleCallback(url) {
            store.updateAccessToken()
        }
    }
#endif
}
