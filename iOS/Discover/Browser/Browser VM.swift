import ScrechKit

@Observable
final class BrowserVM {
    var filterRule = "Minecraft"
    
    private(set) var plans: [MinecraftPlan] = []
    
    private var sortedPlans: [MinecraftPlan] {
        plans.sorted {
            $0.disk < $1.disk
        }
    }
    
    let categories = [
        "Minecraft",
        "VDS",
        "Web",
        "Bot"
    ]
    
    func fetchPlans() async {
        let decoder = JSONDecoder()
        let url = URL(string: "https://plans.bisquit.host/plans/minecraft")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url!)
            let fetchedPlans = try decoder.decode([MinecraftPlan].self, from: data)
            
            plans = fetchedPlans
        } catch {
            print("Error:", error)
        }
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
