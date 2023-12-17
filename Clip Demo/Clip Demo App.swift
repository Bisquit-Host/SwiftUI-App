import ScrechKit
import TipKit
import SafariCover
import Pow

@main
struct Clip_DemoApp: App {
    @StateObject private var settings = SettingsStorage()
    private var navState = NavState()
    
    var body: some Scene {
        WindowGroup {
            LoginContainer()
                .environment(navState)
                .environment(ServerListVM())
                .environmentObject(settings)
//                .task {
//                    try? await Tips.configure {
//                        DisplayFrequency(.immediate)
//                    }
//#if DEBUG
//                    Tips.showAllTips()
//#endif
//                }
        }
    }
}
