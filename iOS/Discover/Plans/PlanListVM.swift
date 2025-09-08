import ScrechKit

@Observable
final class PlanListVM {
    var selectedCategory: Plan = .game
    
    private(set) var mcPlans: [MinecraftPlan] = []
    private(set) var mcruPlans: [MinecraftPlan] = []
    private(set) var vdsPlans: [VdsPlan] = []
    private(set) var webPlans: [WebPlan] = []
    private(set) var botPlans: [BotPlan] = []
    
    func currencyImage(_ currency: String) -> String {
        switch currency {
        case "₽": "rublesign.square"
        case "€": "eurosign.square"
        default:  "exclamationmark.triangle"
        }
    }
    
    func fetchAllPlans() async {
        mcPlans = await fetchPlans(.game, as: MinecraftPlan.self).filter {
            $0.location == "GERMANY"
        }
        
        mcruPlans = await fetchPlans(.game, as: MinecraftPlan.self).filter {
            $0.location == "RUSSIA"
        }
        
        vdsPlans = await fetchPlans(.cloud, as: VdsPlan.self)
        webPlans = await fetchPlans(.web, as: WebPlan.self)
        botPlans = await fetchPlans(.bot, as: BotPlan.self)
    }
    
    private func fetchPlans<T: Decodable>(_ category: Plan, as type: T.Type) async -> [T] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard
            let url = URL(string: "https://api-v1.bisquit.host/public-api/" + category.rawValue)
        else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetchedPlans = try decoder.decode([T].self, from: data)
            
            return fetchedPlans
        } catch {
            print("Error:", error)
            return []
        }
    }
}
