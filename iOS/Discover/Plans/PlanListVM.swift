import ScrechKit

@Observable
final class PlanListVM {
    private(set) var gamePlans: [UniversalPlan] = []
    private(set) var cloudPlans: [UniversalPlan] = []
    private(set) var webPlans: [UniversalPlan] = []
    private(set) var botPlans: [UniversalPlan] = []
    
    func currencyImage(_ currency: String) -> String {
        switch currency {
        case "₽": "rublesign.square"
        case "€": "eurosign.square"
        default:  "exclamationmark.triangle"
        }
    }
    
    func fetchAllPlans() async {
        if let fetchedCloudPlans = await fetchPlans(.cloud)?.result.packages {
            cloudPlans = fetchedCloudPlans
        }
        
        if let fetchedBotPlans = await fetchPlans(.bot)?.result.packages {
            botPlans = fetchedBotPlans
        }
        
        if let fetchedGamePlans = await fetchPlans(.game)?.result.packages {
            gamePlans = fetchedGamePlans
        }
        
        if let fetchedWebPlans = await fetchPlans(.web)?.result.packages {
            webPlans = fetchedWebPlans
        }
    }
    
    private func fetchPlans(_ category: PlanType) async -> PlanResponse? {
        guard
            let url = URL(string: "https://api-v1.bisquit.host/public-api/" + category.rawValue)
        else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetchedPlans = try decoder.decode(PlanResponse.self, from: data)
            
            return fetchedPlans
        } catch {
            print("Error:", error)
            return nil
        }
    }
}
