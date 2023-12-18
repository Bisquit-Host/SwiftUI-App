import ScrechKit
import PteroNet

final class SettingsStorage: ObservableObject {
    @Published var updateServers = false // Triggers update on pull gesture
    
    // MARK: - Auth
    @AppStorage("isApiKeyValid") var isApiKeyValid = false
    @AppStorage("useBiometry") var useBiometry = false
    
    // MARK: - App Style/Design
    @AppStorage("designCode") var designCode = 0
    @AppStorage("transparentSheet") var transparentSheet = true
    @AppStorage("transparentList") var transparentList = false
    
#if !os(macOS)
    @AppStorage("backgroundColor") var backgroundColor: Color = .black
#endif
    
    // MARK: - Console
    @AppStorage("spamEnabled") var spamEnabled = false
    //    @AppStorage("coloredTextEnabled") var coloredTextEnabled = true
    @AppStorage("consoleFontSize") var consoleFontSize = 10.0
    //@AppStorage("consoleFontDesign") var consoleFontDesign = 1
    
    // MARK: - Other
    @AppStorage("currentIcon") var currentIcon = "Primary Icon"
    @AppStorage("showFullFilePath") var showFullFilePath = false
    @AppStorage("preferredCurrency") var preferredCurrency = "₽"
    @AppStorage("lastTabPanel") var lastTabPanel: Tabs = .info
    @AppStorage("tabViewBouncesDown") var tabViewBouncesDown = true
    @AppStorage("animateTabbar") var animatedTabbar = false
#if os(iOS)
    @AppStorage("last_tab_panel_info") var last_tab_panel_info: TabInfo = .relative
#endif
    
    // MARK: - Beta
    @AppStorage("adminMode") var adminMode = false
    @AppStorage("adminServerList") var adminServerList = false
    @AppStorage("enableBisquitFall") var enableBisquitFall = false
    @AppStorage("widgetCpuUsage") var widgetCpuUsage = 0.0
    @AppStorage("widgetRamUsage") var widgetRamUsage = 0.0
    //    @AppStorage("browserCategory") var browserCategory = "Minecraft"
    
    func authSucced() {
        delay {
            withAnimation {
                self.isApiKeyValid = true
            }
        }
    }
    
    func switchPreferredCurrency() {
        let currencySwitchMap = [
            "₽": "€",
            "€": "$",
            "$": "₽"
        ]
        
        if let nextCurrency = currencySwitchMap[preferredCurrency] {
            preferredCurrency = nextCurrency
        }
    }
}
