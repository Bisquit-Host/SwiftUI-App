import ScrechKit
import TipKit
import Algorithms
import OSLog
import Kingfisher

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
struct BisquitHost: App {
    private var nav = NavState()
    @StateObject private var store = ValueStore()
    
#if !os(watchOS)
    @Environment(\.scenePhase) private var phase
#endif
    
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif
    
    init() {
        ImageCache.default.diskStorage.config.sizeLimit = 1024 * 1024 * 1024

        do {
            try Tips.configure([.displayFrequency(.immediate), .datastoreLocation(.groupContainer(identifier: "group.Bisquit-host")), .cloudKitContainer(.automatic)])
        } catch {
            Logger().error("Error initializing TipKit \(error)")
        }
#if canImport(MetricKit)
        _ = MetricKitManager.shared
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
#if canImport(CoreSpotlight)
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlightActivity)
#endif
        }
        .environment(nav)
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
    
#if canImport(CoreSpotlight)
    private func handleSpotlightActivity(_ activity: NSUserActivity) {
        guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }
#if !os(visionOS)
        Task {
            try? await Task.sleep(for: .seconds(0.4))
            nav.navigate(.toPanel(id))
        }
#endif
    }
#endif
}
