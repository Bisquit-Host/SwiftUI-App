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
#if os(iOS) || os(visionOS)
    private var showOAuth2FASheet: Binding<Bool> {
        Binding(
            get: { billingOAuth.showTwoFASheet },
            set: { billingOAuth.showTwoFASheet = $0 }
        )
    }
#endif
    
    var body: some View {
        HomeTabView()
            .animation(.default, value: store.isApiKeyValid)
            .environment(vm)
#if os(iOS) || os(visionOS)
            .environment(billingOAuth)
            .environment(biometry)
            .confettiOverlay()
            .environment(confetti)
            .sheet(showOAuth2FASheet) {
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
                linking.handleDeepLink($0)
                
#if os(iOS) || os(visionOS)
                billingOAuth.handleCallback($0) {
                    store.updateAccessToken()
                }
#endif
            }
            .alert("Authentication with session", isPresented: $linking.alertAuth) {
                Button("Confirm", role: .confirm, action: auth)
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
}
