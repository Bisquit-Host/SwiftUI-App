import ScrechKit
import SwiftData
import TipKit
import SafariCover

#if canImport(Pow)
import Pow
#endif

@main
struct BisquitHostApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    @StateObject private var settings = ValueStorage()
    private var navState = NavState()
#if !os(macOS)
    private var linking = DeepLinkVM()
#endif
    private var network = NetworkVM()
    
    private let container: ModelContainer
    
    init() {
        let schema = Schema([
            APIKey.self
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
#if !os(macOS)
                .onOpenURL { url in
                    linking.handleDeepLink(
                        navState,
                        settings: settings,
                        url: url
                    )
                }
#endif
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
        
#if os(visionOS)
        WindowGroup(id: "console") {
            Text("Console")
        }
        
        WindowGroup(id: "QuickLook", for: FileLink.self) { $file in
            NavigationStack {
                QuickLookFile($file)
            }
        }
#endif
        
#if os(macOS)
        Settings {
            AppSettings()
                .environment(navState)
                .environmentObject(settings)
        }
#endif
    }
}
