import ScrechKit
import SwiftData
import TipKit
import GameKit
import Algorithms
import CoreSpotlight
import Pow
import GaypadKit

#if canImport(SettingsKit)
import SettingsKit
#endif

@main
struct BisquitHostApp: App {
    @StateObject private var store = ValueStore()
    private var nav = NavState()
    private var navModel = NavModel()
    
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
            // AppContainer()
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlightActivity)
        }
        .environment(nav)
        .modelContainer(container)
        .environmentObject(store)
        .defaultAppStorage(.init(suiteName: "group.Bisquit-host")!)
#if canImport(SettingsKit)
        .settings(design: .sidebar) {
            SettingsTab(.new(title: "General", image: Image(systemName: "gear")), id: "general") {
                SettingsSubtab(.noSelection, id: "no-selection") {
                    GeneralSettings()
                }
            }
            
            //            SettingsTab(.new(title: "Layout", image: Image(systemName: "paintbrush")), id: "layout", color: .yellow) {
            //                SettingsSubtab(.noSelection, id: "no-selection") {
            //                    LayoutSettings()
            //                        .environmentObject(store)
            //                }
            //            }
        }
#endif
        .environment(navModel)        
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
#endif
    }
    
    private func handleSpotlightActivity(_ activity: NSUserActivity) {
        guard
            let _ = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String
        else {
            return
        }
    }
}
