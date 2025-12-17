import SwiftUI
import SwiftData
import TipKit
import GameKit
import Algorithms
import CoreSpotlight
import Pow
import GaypadKit

@main
struct BisquitHost: App {
    private var nav = NavState()
    @StateObject private var store = ValueStore()
    @State private var securityTasks = SecurityTasks()
    
    private let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: APIKey.self)
        } catch {
            fatalError("Failed to create model container")
        }
        
        try? Tips.configure([.displayFrequency(.immediate)])
        
        _ = MetricKitManager.shared
        
        if ValueStore().enableGameCenter {
            GKLocalPlayer.local.authenticateHandler = { _, error in
                guard error == nil else {
                    print(error?.localizedDescription ?? "❌ Game Center auth failed")
                    return
                }
                
                print("✅ Game Center authenticated")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            DashboardShell()
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlightActivity)
                .environment(securityTasks)
                .onFirstAppear {
                    await securityTasks.startCheck()
                }
        }
        .environment(nav)
        .environmentObject(store)
        .modelContainer(container)
        .defaultAppStorage(.init(suiteName: "group.Bisquit-host")!)
        //#if os(macOS)
        //        .windowStyle(.hiddenTitleBar)
        //#endif
        
        Settings {
            NavigationStack {
                SettingsView()
            }
            .environmentObject(store)
        }
    }
    
    private func handleSpotlightActivity(_ activity: NSUserActivity) {
        guard let _ = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }
    }
}
