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
        
        guard let url = URL(string: "\(Endpoint.basePath)\(endpointPath)") else {
            SystemAlert.error("Invalid URL")
            return
        }
        
        guard let accessToken = accessToken() else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                return
            }
            
            try assign(data)
        } catch {
            SystemAlert.error("Error loading \(endpointPath) services", subtitle: error.localizedDescription)
        }
    }
}
