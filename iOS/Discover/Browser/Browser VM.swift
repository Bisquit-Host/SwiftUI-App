import ScrechKit

@Observable
final class BrowserVM {
    var filterRule = "Minecraft"
    
    private(set) var plans: [MinecraftPlan] = []
    
    let categories = [
        "Minecraft",
        "VDS",
        "Web",
        "Bot"
    ]
    
    func fetchPlans() async -> [MinecraftPlan] {
        let decoder = JSONDecoder()
        
        guard
            let url = URL(string: "https://plans.bisquit.host/plans/minecraft")
        else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetchedPlans = try decoder.decode([MinecraftPlan].self, from: data)
            
            return fetchedPlans
        } catch {
            print("Error:", error)
            return []
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
