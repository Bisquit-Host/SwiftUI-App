import ScrechKit

@Observable
final class BrowserVM {
    var chosenLink = ""
    var filterRule = "Minecraft"
    var currencyImg = "rublesign.square"
    var showSafari = false
    
    private var plans: [Plan] = []
    
    private var sortedPlans: [Plan] {
        plans.sorted {
            $0.disk < $1.disk
        }
    }
    
    var filteredPlans: [Plan] {
        if filterRule.isEmpty {
            sortedPlans
        } else {
            sortedPlans.filter {
                $0.type.lowercased().contains(filterRule.lowercased())
            }
        }
    }
    
    func fetchPlans() async {
        
    }
    
    func currencyImage(_ currency: String) -> String {
        switch currency {
        case "₽": "rublesign.square"
        case "€": "eurosign.square"
        case "$": "dollarsign.square"
        default:  "exclamationmark.triangle"
        }
    }
}
