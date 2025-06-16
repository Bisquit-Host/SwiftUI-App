import ScrechKit
import PteroNet

final class ValueStore: ObservableObject {
#if os(macOS)
    @AppStorage("nav_mode") var navMode: NavMode?
#endif
    
    @AppStorage("enable_game_center") var enableGameCenter = true
    @AppStorage("hide_status_bar") var hideStatusBar = false
    @AppStorage("hide_server_names") var hideServerNames = false
    @AppStorage("color_theme") var colorTheme: ColorTheme = .system
    @Published var updateServers = false // Triggers server card update
    @Published var updateBackground = false // Triggers background image update
    
    // MARK: - Auth
    @AppStorage("isApiKeyValid") var isApiKeyValid = false
    @AppStorage("useBiometry") var useBiometry = false
    @AppStorage("show_dynamic_island_badge") var showDynamicIslandBadge = true
    
    // MARK: - Console
    @AppStorage("spamEnabled") var spamEnabled = false
    @AppStorage("consoleFontSize") var consoleFontSize = 10.0
    //    @AppStorage("coloredTextEnabled") var coloredTextEnabled = true
    //    @AppStorage("consoleFontDesign") var consoleFontDesign = 1
    
    // MARK: - Other
#if !os(macOS)
    @AppStorage("last_tab_panel") var lastTabPanel: Tabs = .info
#endif
    @AppStorage("showFullFilePath") var showFullFilePath = false
    @AppStorage("preferredCurrency") var preferredCurrency = "₽"
    @AppStorage("tabViewBouncesDown") var tabViewBouncesDown = true
    @AppStorage("rawStartupCommand") var rawStartupCommand = false
#if os(iOS)
    @AppStorage("currentIcon") var currentIcon: Icon = .def
    @AppStorage("lastInfoTab") var lastInfoTab: TabInfo = .relative
    @AppStorage("contactsProviderEnabled") var contactsProviderEnabled = false
#endif
    
    // MARK: - Beta
    @AppStorage("dev_mode") var devMode = false
    @AppStorage("adminServerList") var adminServerList = false
    @AppStorage("enable_bisquit_fall") var enableBisquitFall = false
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
