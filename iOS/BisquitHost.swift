import ScrechKit
import SwiftData
import TipKit
import GameKit
import Algorithms
import OSLog

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
        
        do {
            try Tips.configure([.displayFrequency(.immediate), .datastoreLocation(.groupContainer(identifier: "group.Bisquit-host")), .cloudKitContainer(.automatic)])
        } catch {
            Logger().error("Error initializing TipKit \(error)")
        }
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
            if newPhase == .background {
                BackgroundTaskManager.scheduleAppRefresh()
            }
        }
        .backgroundTask(.appRefresh("host.bisquit.Bisquit-Host.Background-Task")) {
            await BackgroundTaskManager.handleAppRefresh()
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
