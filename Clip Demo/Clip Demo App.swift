import ScrechKit
import TipKit
import Pow
import SafariCover

@main
struct ClipDemoApp: App {
    @StateObject private var settings = SettingsStorage()
    private var navState = NavState()
    
    var body: some Scene {
        WindowGroup {
            LoginContainer()
                .environment(navState)
                .environment(ServerListVM())
                .environmentObject(settings)
        }
    }
}
