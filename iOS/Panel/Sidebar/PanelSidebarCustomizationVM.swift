import Foundation

@Observable
final class PanelSidebarCustomizationVM {
    private let hiddenTabsDefaultsKey = "panel.sidebar.hiddenTabs.v1"
    private let placementDefaultsKey = "panel.sidebar.placement.v1"
    private let backgroundStyleDefaultsKey = PanelSidebarBackgroundStyle.defaultsKey
    
    var tabVisibility: [Tabs: Bool] {
        didSet {
            persistHiddenTabs()
        }
    }
    
    var placement: PanelSidebarPlacement {
        didSet {
            persistPlacement()
        }
    }
    
    var backgroundStyle: PanelSidebarBackgroundStyle {
        didSet {
            persistBackgroundStyle()
        }
    }
    
    init() {
        tabVisibility = Dictionary(uniqueKeysWithValues: Tabs.allCases.map {
            ($0, true)
        })
        
        placement = .left
        backgroundStyle = PanelSidebarBackgroundStyle.selectableCases.first ?? .ultraThinMaterial
        
        loadHiddenTabs()
        loadPlacement()
        loadBackgroundStyle()
    }
    
    var visibleSections: [PanelSidebarSection] {
        PanelSidebarSection.all.compactMap { section in
            let visibleTabs = section.tabs.filter {
                isTabVisible($0)
            }
            
            guard !visibleTabs.isEmpty else { return nil }
            return PanelSidebarSection(key: section.key, tabs: visibleTabs)
        }
    }
    
    var firstVisibleTab: Tabs? {
        PanelSidebarSection.all
            .flatMap(\.tabs)
            .first { isTabVisible($0) }
    }
    
    func isTabVisible(_ tab: Tabs) -> Bool {
        tabVisibility[tab, default: true]
    }
    
    func setTabVisible(_ isVisible: Bool, for tab: Tabs) {
        tabVisibility[tab] = isVisible
    }
    
    func toggleTabVisibility(_ tab: Tabs) {
        setTabVisible(!isTabVisible(tab), for: tab)
    }
    
    func reset() {
        tabVisibility = Dictionary(uniqueKeysWithValues: Tabs.allCases.map { ($0, true) })
        placement = .left
        backgroundStyle = PanelSidebarBackgroundStyle.selectableCases.first ?? .ultraThinMaterial
    }
}

private extension PanelSidebarCustomizationVM {
    func loadHiddenTabs() {
        guard let hiddenTabs = UserDefaults.standard.array(forKey: hiddenTabsDefaultsKey) as? [String] else {
            return
        }
        
        let hiddenTabIDs = Set(hiddenTabs)
        var visibility = Dictionary(uniqueKeysWithValues: Tabs.allCases.map { ($0, true) })
        
        for tab in Tabs.allCases {
            if hiddenTabIDs.contains(tab.visibilityID) {
                visibility[tab] = false
            }
        }
        
        tabVisibility = visibility
    }
    
    func persistHiddenTabs() {
        let hiddenTabs = Tabs.allCases
            .filter { tabVisibility[$0, default: true] == false }
            .map(\.visibilityID)
        
        UserDefaults.standard.set(hiddenTabs, forKey: hiddenTabsDefaultsKey)
    }
    
    func loadPlacement() {
        guard
            let rawValue = UserDefaults.standard.string(forKey: placementDefaultsKey),
            let placement = PanelSidebarPlacement(rawValue: rawValue)
        else {
            return
        }
        
        self.placement = placement
    }
    
    func persistPlacement() {
        UserDefaults.standard.set(placement.rawValue, forKey: placementDefaultsKey)
    }
    
    func loadBackgroundStyle() {
        guard let rawValue = UserDefaults.standard.string(forKey: backgroundStyleDefaultsKey) else {
            return
        }
        
        guard let backgroundStyle = PanelSidebarBackgroundStyle(rawValue: rawValue) else {
            self.backgroundStyle = PanelSidebarBackgroundStyle.selectableCases.first ?? .ultraThinMaterial
            persistBackgroundStyle()
            return
        }
        
        guard PanelSidebarBackgroundStyle.selectableCases.contains(backgroundStyle) else {
            self.backgroundStyle = PanelSidebarBackgroundStyle.selectableCases.first ?? .ultraThinMaterial
            persistBackgroundStyle()
            return
        }
        
        self.backgroundStyle = backgroundStyle
    }
    
    func persistBackgroundStyle() {
        UserDefaults.standard.set(backgroundStyle.rawValue, forKey: backgroundStyleDefaultsKey)
    }
}
