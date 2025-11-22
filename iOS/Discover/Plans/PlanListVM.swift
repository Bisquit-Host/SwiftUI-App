import SwiftUI

@Observable
final class PlanListVM {
    private(set) var gamePlans:     [UniversalPlan] = []
    private(set) var cloudPlans:    [UniversalPlan] = []
    private(set) var webPlans:      [UniversalPlan] = []
    private(set) var botPlans:      [UniversalPlan] = []
    private(set) var gameLocations: [PlanLocation] = []
    
    func currencyImage(_ currency: String) -> String {
        switch currency {
        case "₽": "rublesign.square"
        case "€": "eurosign.square"
        default:  "exclamationmark.triangle"
        }
    }
    
    func fetchAllPlans() async {
        if let fetchedGamePlans = await fetchPlans(.game)?.result {
            gamePlans = fetchedGamePlans.packages
            
            if let locations = fetchedGamePlans.locations {
                gameLocations = locations
            }
        }
        
        if let fetchedCloudPlans = await fetchPlans(.cloud)?.result.packages {
            cloudPlans = fetchedCloudPlans
        }
        
        if let fetchedBotPlans = await fetchPlans(.bot)?.result.packages {
            botPlans = fetchedBotPlans
        }
        
        if let fetchedWebPlans = await fetchPlans(.web)?.result.packages {
            webPlans = fetchedWebPlans
        }
    }
    
    private func fetchPlans(_ category: PlanType) async -> PlanResponse? {
        let link = "https://api-v1.bisquit.host/public-api/" + category.rawValue
        
        guard let url = URL(string: link) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let fetchedPlans = try decoder.decode(PlanResponse.self, from: data)
            return fetchedPlans
        } catch {
            print("Error:", error)
            return nil
        }
    }
}
