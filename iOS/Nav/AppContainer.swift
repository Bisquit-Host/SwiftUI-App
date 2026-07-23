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
    
#if os(iOS)
    @State private var panelSignIn = PanelSignInVM()
    @Environment(\.openURL) private var openURL
#endif
    
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
#if os(iOS) || os(visionOS)
        @Bindable var billingOAuth = billingOAuth
#endif
        
#if os(iOS)
        @Bindable var panelSignIn = panelSignIn
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
            handleIncomingURL($0)
        }
#if os(iOS)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUniversalLinkActivity)
        .onChange(of: store.accessToken) { _, accessToken in
            panelSignIn.resume(accessToken: accessToken)
        }
        .alert(panelSignIn.confirmationTitle, isPresented: $panelSignIn.isShowingConfirmation) {
            Button("Sign In", action: approvePanelSignIn)
            Button("Cancel", role: .cancel, action: panelSignIn.cancel)
        } message: {
            Text(panelSignIn.confirmationMessage)
        }
        .alert("Panel Sign In Failed", isPresented: $panelSignIn.isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(panelSignIn.errorMessage)
        }
#endif
    }
    
    private func handleIncomingURL(_ url: URL) {
        Logger().info("🔗 Deeplink: \(url)")
        
#if os(iOS)
        if panelSignIn.handle(url, accessToken: store.accessToken) {
            return
        }
#endif
        
#if os(iOS) || os(visionOS)
        billingOAuth.handleCallback(url) {
            store.updateAccessToken()
        }
#endif
    }
    
#if os(iOS)
    private func handleUniversalLinkActivity(_ activity: NSUserActivity) {
        guard let url = activity.webpageURL else {
            Logger().error("🔗 Universal link missing URL")
            return
        }
        
        Logger().info("🔗 Universal link: \(url)")
        handleIncomingURL(url)
    }
    
    private func approvePanelSignIn() {
        Task {
            guard let redirectURL = await panelSignIn.approve(accessToken: store.accessToken) else {
                return
            }
            
            openURL(redirectURL)
        }
    }
#endif
}
