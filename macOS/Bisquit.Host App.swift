import ScrechKit
import SwiftData
import TipKit
import GameKit

#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

#if canImport(Algorithms)
import Algorithms
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
    private var navState = NavState()
    
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
        
        _ = MetricKitManager.shared
        
        GKLocalPlayer.local.authenticateHandler = { _, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Game Center auth failed")
                return
            }
            
            print("Game Center authenticated")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//            AppContainer()
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlightActivity)
        }
        .environment(navState)
        .modelContainer(container)
        .environmentObject(store)
        .defaultAppStorage(.init(suiteName: "group.Bisquit-host")!)
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
#endif
#if os(macOS)
        Settings {
            AppSettings()
                .environment(navState)
                .environmentObject(store)
        }
#endif
    }
    
    private func handleSpotlightActivity(_ activity: NSUserActivity) {
        guard
            let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String
        else {
            return
        }
    }
}
