import ScrechKit
import PteroNet

#if canImport(Appearance)
import Appearance
#endif

final class ValueStore: ObservableObject {
    // MARK: - Settings
    @AppStorage("settings_selexted_tab") var settingsSelectedTab: AppSettingsTab = .account
    @AppStorage("big_ass_animations") var bigAssAnimations = true
    
    // MARK: - Billing
    
    /// milliseconds
    @AppStorage("test_expires_in") var accessTokenExpiresIn = 0
    @AppStorage("test_last_billing_token_refresh") var lastBillingTokenRefresh: Date?
    
#if os(visionOS)
    //    @AppStorage("show_info") var showInfo = true
    @AppStorage("show_power_buttons") var showPowerButtons = true
#endif
    
#if os(tvOS) || os(watchOS) || os(visionOS)
    @AppStorage("tab_panel") var panelTab: PanelTab = .info
#endif
    @AppStorage("push_token") var pushToken: String?
    
    // MARK: - Server List/Card
    @AppStorage("compact_server_list") var compactServerList = false
    @AppStorage("server_card_description") var serverCardDescription = true
    @AppStorage("hide_server_names") var hideServerNames = false
    @Published var updateServers = false // Triggers server card update
    
    @AppStorage("enable_game_center") var enableGameCenter = true
#if os(iOS)
    @AppStorage("hide_status_bar") var hideStatusBar = false
#endif
    @Published var updateBackground = false // Triggers background image update
    
#if canImport(Appearance)
    @AppStorage("color_theme") var appearance: Appearance = .system
#endif
    
    // MARK: - Auth
    @AppStorage("isApiKeyValid") var isApiKeyValid = false
    @AppStorage("useBiometry") var useBiometry = false
    
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
    @AppStorage("tabViewBouncesDown") var tabViewBouncesDown = true
    @AppStorage("rawStartupCommand") var rawStartupCommand = false
#if os(iOS)
    @AppStorage("currentIcon") var currentIcon: Icon = .def
    @AppStorage("lastInfoTab") var lastInfoTab: TabInfo = .relative
    @AppStorage("contactsProviderEnabled") var contactsProviderEnabled = false
    @AppStorage("selected_account_tab") var selectedAccountTab = 0
#endif
    
    // MARK: - Beta
    @AppStorage("dev_mode") var devMode = false
    @AppStorage("adminServerList") var adminServerList = false
    @AppStorage("enable_bisquit_fall") var enableBisquitFall = false
    @AppStorage("widgetCpuUsage") var widgetCpuUsage = 0.0
    @AppStorage("widgetRamUsage") var widgetRamUsage = 0.0
    @AppStorage("saveMetrics") var saveMetrics = false
    
    @Published var accessToken = Keychain.load(key: "access_token")
    
    func updateAccessToken() {
        accessToken = Keychain.load(key: "access_token")
    }
    
    func authSucced() {
        Task {
            try await Task.sleep(for: .seconds(1))
            
            withAnimation {
                self.isApiKeyValid = true
            }
        }
    }
}
