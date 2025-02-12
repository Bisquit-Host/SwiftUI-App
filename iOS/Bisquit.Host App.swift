import ScrechKit
import SwiftData
import TipKit
import GameKit

#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

#if canImport(SafariCover)
import SafariCover
#endif

#if canImport(Pow)
import Pow
#endif

@main
struct BisquitHostApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    @StateObject private var store = ValueStore()
    private var navState = NavState()
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
        
#if os(watchOS)
        GKLocalPlayer.local.authenticateHandler = { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Game Center authentication failed")
                return
            }
            
            print("Game Center authenticated")
        }
#else
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
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
        .environment(navState)
        .modelContainer(container)
        .environmentObject(store)
        .defaultAppStorage(.init(suiteName: "group.Bisquit-host")!)
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
#endif
        
#if canImport(AlertKit)
        .onChange(of: network.isNetworkSatisfied) { _, status in
            guard let status, status else {
                SystemAlert.networkError()
                return
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
                .environmentObject(store)
        }
#endif
    }
    
#if canImport(CoreSpotlight) && !os(tvOS)
    func handleSpotlightActivity(_ activity: NSUserActivity) {
        guard
            let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String
        else {
            return
        }
        
#warning("macOS")
#if !os(macOS)
        delay(0.4) {
            navState.navigate(.toPanel(id))
        }
#endif
    }
#endif
}
