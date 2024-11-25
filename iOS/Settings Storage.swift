import ScrechKit
import PteroNet

final class ValueStorage: ObservableObject {
    @Published var updateServers = false // Triggers update on pull gesture
    
    // MARK: - Auth
    @AppStorage("isApiKeyValid") var isApiKeyValid = false
    @AppStorage("useBiometry") var useBiometry = false
    @AppStorage("show_dynamic_island_badge") var showDynamicIslandBadge = true
    
    // MARK: - App Style/Design
    @AppStorage("designCode") var designCode = 0
    @AppStorage("transparentSheet") var transparentSheet = true
    @AppStorage("transparentList") var transparentList = false
    
#if !os(macOS)
    @AppStorage("backgroundColor") var backgroundColor: Color = .black
#endif
    
    // MARK: - Console
    @AppStorage("spamEnabled") var spamEnabled = false
    @AppStorage("consoleFontSize") var consoleFontSize = 10.0
    //    @AppStorage("coloredTextEnabled") var coloredTextEnabled = true
    //@AppStorage("consoleFontDesign") var consoleFontDesign = 1
    
    // MARK: - Other
    @AppStorage("currentIcon") var currentIcon = "Primary Icon"
    @AppStorage("showFullFilePath") var showFullFilePath = false
    @AppStorage("preferredCurrency") var preferredCurrency = "₽"
    @AppStorage("lastTabPanel") var lastTabPanel: Tabs = .info
    @AppStorage("tabViewBouncesDown") var tabViewBouncesDown = true
    @AppStorage("rawStartupCommand") var rawStartupCommand = false
#if os(iOS)
    @AppStorage("lastInfoTab") var lastInfoTab: TabInfo = .relative
    @AppStorage("contactsProviderEnabled") var contactsProviderEnabled = false
#endif
    
    // MARK: - Beta
    @AppStorage("dev_mode") var devMode = false
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
