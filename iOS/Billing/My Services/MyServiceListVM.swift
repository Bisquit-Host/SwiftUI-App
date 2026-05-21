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
    
    var services: [BillingMyService] {
        cloudServices.map { .cloud($0) }
        + gameServices.map { .game($0) }
        + botServices.map { .bot($0) }
    }
    
    var isLoading: Bool {
        isCloudLoading || isGameLoading || isBotLoading
    }
    
    func loadMyServices() async {
        async let cloud: () = fetchMyCloudServices()
        async let game: () = fetchMyGameServices()
        async let bot: () = fetchMyBotServices()
        
        let _ = await (cloud, game, bot)
    }
    
    func fetchMyCloudServices() async {
        await fetchMyServices(endpointPath: "cloud", isLoadingKeyPath: \.isCloudLoading, emptyResponse: []) {
            self.cloudServices = $0
        }
    }
    
    func fetchMyGameServices() async {
        await fetchMyServices(endpointPath: "game", isLoadingKeyPath: \.isGameLoading, emptyResponse: []) {
            self.gameServices = $0
        }
    }
    
    func fetchMyBotServices() async {
        await fetchMyServices(endpointPath: "bot", isLoadingKeyPath: \.isBotLoading, emptyResponse: []) {
            self.botServices = $0
        }
    }
    
    private func fetchMyServices<T: Decodable & Sendable>(
        endpointPath: String,
        isLoadingKeyPath: ReferenceWritableKeyPath<MyServiceListVM, Bool>,
        emptyResponse: T,
        assign: @escaping (T) -> Void
    ) async {
        guard !self[keyPath: isLoadingKeyPath] else { return }
        
        self[keyPath: isLoadingKeyPath] = true
        defer { self[keyPath: isLoadingKeyPath] = false }
        
        guard let accessToken = accessToken() else { return }
        
        guard let result = await fetchMyServicesAPI(
            endpointPath: endpointPath,
            accessToken: accessToken,
            emptyResponse: emptyResponse,
            onBillingError: SystemAlert.error
        ) else { return }
        
        assign(result)
    }
}
