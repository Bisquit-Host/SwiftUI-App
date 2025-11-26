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
struct BisquitHost: App {
    private var nav = NavState()
    @StateObject private var store = ValueStore()
    
#if !os(watchOS)
    @Environment(\.scenePhase) private var phase
#endif
    
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif
    
    private let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: APIKey.self)
        } catch {
            fatalError("Failed to create model container")
        }
        
        try? Tips.configure([.displayFrequency(.immediate)])
        
#if canImport(MetricKit) && !os(tvOS)
        _ = MetricKitManager.shared
#endif
        
#if !DEBUG
        setupGameCenter()
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
#if !os(watchOS)
        .onChange(of: phase) { _, newPhase in
            switch newPhase {
            case .background: BackgroundTaskManager.scheduleAppRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("host.bisquit.Bisquit-Host.Background-Task")) {
            await BackgroundTaskManager.scheduleAppRefresh()
#warning("Implement background tasks")
            //Create an operation that performs the main part of the background task
            //let operation = RefreshAppContentsOperation()
            
            //Provide the background task with an expiration handler that cancels the operation
            //task.expirationHandler = {
            //    operation.cancel()
            //}
            
            // Inform the system that the background task is complete
            // when the operation completes
            //operation.completionBlock = {
            //    task.setTaskCompleted(success: !operation.isCancelled)
            //}
            
            //Start the operation
            //operationQueue.addOperation(operation)
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
    }
    
#if canImport(CoreSpotlight) && !os(tvOS)
    private func handleSpotlightActivity(_ activity: NSUserActivity) {
        guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }
#if !os(macOS) && !os(visionOS)
        Task {
            try await Task.sleep(for: .seconds(0.4))
            nav.navigate(.toPanel(id))
        }
#endif
    }
#endif
    
    private func setupGameCenter() {
        guard ValueStore().enableGameCenter else {
            return
        }
#if os(watchOS)
        GKLocalPlayer.local.authenticateHandler = { error in
            authenticateGameCenter(error)
        }
#else
        GKLocalPlayer.local.authenticateHandler = { _, error in
            authenticateGameCenter(error)
        }
#endif
    }
    
    private func authenticateGameCenter(_ error: Error?) {
        guard error == nil else {
            print(error?.localizedDescription ?? "Game Center authentication failed")
            return
        }
        
        print("Game Center authenticated")
    }
}
