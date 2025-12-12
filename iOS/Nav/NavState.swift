import SwiftUI

@Observable
final class NavState {
#if os(iOS)
    enum RootTab: String, Hashable {
        case billing, pterodactyl
    }
    
    private static let selectedTabDefaultsKey = "nav.selectedTab"
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: "group.Bisquit-host") ?? .standard
    }
    
    var selectedTab: RootTab = .pterodactyl {
        didSet {
            Self.defaults.set(selectedTab.rawValue, forKey: Self.selectedTabDefaultsKey)
        }
    }
    var billingPath = NavigationPath()
    var pterodactylPath = NavigationPath()
    
    init() {
        if
            let rawValue = Self.defaults.string(forKey: Self.selectedTabDefaultsKey),
            let tab = RootTab(rawValue: rawValue)
        {
            selectedTab = tab
        }
    }
    
    func navigate(_ navDestination: NavDestinations) {
        let tab = preferredTab(for: navDestination) ?? selectedTab
        selectedTab = tab
        
        switch tab {
        case .billing:
            billingPath.append(navDestination)
            
        case .pterodactyl:
            pterodactylPath.append(navDestination)
        }
    }
    
    func dismiss() {
        switch selectedTab {
        case .billing:
            guard !billingPath.isEmpty else {
                print("Error: nav path is empty")
                return
            }
            
            billingPath.removeLast()
            
        case .pterodactyl:
            guard !pterodactylPath.isEmpty else {
                print("Error: nav path is empty")
                return
            }
            
            pterodactylPath.removeLast()
        }
    }
    
    func clear() {
        selectedTab = .pterodactyl
        billingPath = .init()
        pterodactylPath = .init()
    }
    
    private func preferredTab(for navDestination: NavDestinations) -> RootTab? {
        switch navDestination {
        case .toBillingDashboard: .billing
        case .toPanel, .toFileManager, .toServerList: .pterodactyl
        case .toSettings: nil
        }
    }
#else
    var path = NavigationPath()
    
    func navigate(_ navDestination: NavDestinations) {
        path.append(navDestination)
    }
    
    func dismiss() {
        guard !path.isEmpty else {
            print("Error: nav path is empty")
            return
        }
        
        path.removeLast()
    }
    
    func clear() {
        path = .init()
    }
#endif
}
