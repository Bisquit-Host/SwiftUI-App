import Foundation

@Observable
final class PanelSidebarCustomizationVM {
    private let defaultsKey = "panel.sidebar.hiddenTabs.v1"
    
    var tabVisibility: [Tabs: Bool] {
        didSet {
            persistHiddenTabs()
        }
    }
    
    init() {
        tabVisibility = Dictionary(uniqueKeysWithValues: Tabs.allCases.map {
            ($0, true)
        })
        
        loadHiddenTabs()
    }
    
    var visibleSections: [PanelSidebarSection] {
        PanelSidebarSection.all.compactMap { section in
            let visibleTabs = section.tabs.filter {
                isTabVisible($0)
            }
            
            guard !visibleTabs.isEmpty else { return nil }
            return PanelSidebarSection(title: section.title, tabs: visibleTabs)
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
    }
}

private extension PanelSidebarCustomizationVM {
    func loadHiddenTabs() {
        guard let hiddenTabs = UserDefaults.standard.array(forKey: defaultsKey) as? [String] else {
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
        
        UserDefaults.standard.set(hiddenTabs, forKey: defaultsKey)
    }
}
