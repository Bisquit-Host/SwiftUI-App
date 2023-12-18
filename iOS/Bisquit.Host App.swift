import ScrechKit
import SwiftData
import TipKit

#if canImport(Pow)
import Pow
#endif

@main
struct BisquitHostApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    private var navState = NavState()
    private var linking = LinkingVM()
    @StateObject private var settings = SettingsStorage()
    
    private var network = NetworkVM()
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: APIKey.self)
        } catch {
            fatalError("Failed to create model container")
        }
        
        try? Tips.configure([
            .displayFrequency(.immediate)
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            //            if settings.isApiKeyValid {
            AppContainer()
                .onOpenURL { url in
                    linking.handleDeepLink(
                        navState,
                        settings: settings,
                        url: url
                    )
                }
            //                    .alert("Error", isPresented: $linking.alertError) {
            //
            //                    } message: {
            //                        Text(linking.errorMessage)
            //                    }
            //            } else {
            //                LoginContainer()
            //                    .environment(ServerListVM())
            //            }
        }
        .environment(navState)
        .modelContainer(container)
        .environmentObject(settings)
        .defaultAppStorage(.init(suiteName: "group.Bisquit-host")!)
#if os(iOS)
        .onChange(of: network.isNetworkSatisfied) { _, status in
            if !status {
                SystemAlert.networkError()
            }
        }
#endif
        
#if os(macOS)
        Settings {
            AppSettings()
                .environmentObject(settings)
        }
#endif
    }
}
