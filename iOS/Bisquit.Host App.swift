import ScrechKit
import SwiftData
import TipKit
import GameKit
import Algorithms

#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

#if canImport(SafariCover)
import SafariCover
#endif

#if canImport(Pow)
import Pow
#endif

#if canImport(GaypadKit)
import GaypadKit
#endif

@main
struct BisquitHostApp: App {
    @StateObject private var store = ValueStore()
    private var nav = NavState()
    
#if os(iOS) || os(tvOS) || os(visionOS)
    @Environment(\.scenePhase) private var phase
#endif
    
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
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
        
#if canImport(MetricKit) && !os(tvOS)
        _ = MetricKitManager.shared
#endif
        
#if os(watchOS)
        GKLocalPlayer.local.authenticateHandler = { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Game Center authentication failed")
                return
            }
            
            print("Game Center authenticated")
        }
#else
        GKLocalPlayer.local.authenticateHandler = { _, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Game Center authentication failed")
                return
            }
            
            print("Game Center authenticated")
        }
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
#if canImport(CoreSpotlight) && !os(tvOS)
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlightActivity)
#endif
        }
        .environment(nav)
        .modelContainer(container)
        .environmentObject(store)
        .defaultAppStorage(.init(suiteName: "group.Bisquit-host")!)
#if os(iOS) || os(tvOS) || os(visionOS)
        .onChange(of: phase) { _, newPhase in
            switch newPhase {
            case .background: BackgroundTaskManager.scheduleAppRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("host.bisquit.Bisquit-Host.Background-Task")) {
            ServerListVM().loadServers()
        }
#endif
        
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
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
                .environmentObject(store)
        }
#endif
    }
    
#if canImport(CoreSpotlight) && !os(tvOS)
    private func handleSpotlightActivity(_ activity: NSUserActivity) {
        guard
            let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String
        else {
            return
        }
        
#if !os(macOS)
        delay(0.4) {
            nav.navigate(.toPanel(id))
        }
#endif
    }
#endif
}
