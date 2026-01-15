import Foundation
import BisquitoNet
import PteroNet

@Observable
final class MyServiceListVM {
    var cloudServices: [CloudServiceSummary] = []
    var gameServices: [BillingGameServiceSummary] = []
    var botServices: [BillingBotServiceSummary] = []
    
    var isCloudLoading = false
    var isGameLoading = false
    var isBotLoading = false
    
    func loadMyServices() async {
        async let cloud: () = fetchMyCloudServices()
        async let game: () = fetchMyGameServices()
        async let bot: () = fetchMyBotServices()
        
        let _ = await (cloud, game, bot)
    }
    
    func fetchMyCloudServices() async {
        await fetchMyServices(endpointPath: "cloud", isLoadingKeyPath: \.isCloudLoading) { data in
            self.cloudServices = try BigAssDecoder.decode([CloudServiceSummary].self, from: data)
        }
    }
    
    func fetchMyGameServices() async {
        await fetchMyServices(endpointPath: "game", isLoadingKeyPath: \.isGameLoading) { data in
            self.gameServices = try BigAssDecoder.decode([BillingGameServiceSummary].self, from: data)
        }
    }
    
    func fetchMyBotServices() async {
        await fetchMyServices(endpointPath: "bot", isLoadingKeyPath: \.isBotLoading) { data in
            self.botServices = try BigAssDecoder.decode([BillingBotServiceSummary].self, from: data)
        }
    }
    
    private func fetchMyServices(
        endpointPath: String,
        isLoadingKeyPath: ReferenceWritableKeyPath<MyServiceListVM, Bool>,
        assign: @escaping (Data) throws -> Void
    ) async {
        guard !self[keyPath: isLoadingKeyPath] else { return }
        
        self[keyPath: isLoadingKeyPath] = true
        defer { self[keyPath: isLoadingKeyPath] = false }
        
        guard let accessToken = accessToken() else { return }
        
        guard let data = await fetchMyServicesAPI(
            endpointPath: endpointPath,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) else { return }
        
        do {
            try assign(data)
        } catch {
            SystemAlert.error("Error loading services", subtitle: error.localizedDescription)
        }
    }
}
