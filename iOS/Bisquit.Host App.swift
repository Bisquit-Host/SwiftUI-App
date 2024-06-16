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
    
    @StateObject private var settings = SettingsStorage()
    private var navState = NavState()
    private var linking = LinkingVM()
    private var network = NetworkVM()
    
    private let container: ModelContainer
    
    init() {
        let schema = Schema([
            APIKey.self,
        ])
        
        do {
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create model container")
        }
        
        try? Tips.configure([
            .displayFrequency(.immediate)
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
                .onOpenURL { url in
                    linking.handleDeepLink(
                        navState,
                        settings: settings,
                        url: url
                    )
                }
            //                .alert("Error", isPresented: $linking.alertError) {
            //
            //                } message: {
            //                    Text(linking.errorMessage)
            //                }
        }
        .environment(navState)
        .modelContainer(container)
        .environmentObject(settings)
        .defaultAppStorage(.init(suiteName: "group.Bisquit-host")!)
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
#endif
        
#if canImport(AlertKit)
        .onChange(of: network.isNetworkSatisfied) { _, status in
            guard let status else {
                return
            }
            
            if !status {
                SystemAlert.networkError()
            }
        }
#endif
        
        WindowGroup(id: "console") {
            Text("Console")
        }
        
#if os(macOS)
        Settings {
            AppSettings()
                .environment(navState)
                .environmentObject(settings)
        }
#endif
    }
}
