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
        guard !isCloudLoading else { return }
        
        isCloudLoading = true
        defer { isCloudLoading = false }
        
        guard let url = URL(string: "\(Endpoint.basePath)cloud") else {
            Logger().error("Invalid URL")
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
            
            cloudServices = try BigAssDecoder.decode([CloudServiceSummary].self, from: data)
        } catch {
            SystemAlert.error("Error loading cloud services", subtitle: error.localizedDescription)
        }
    }
    
    func fetchMyGameServices() async {
        guard !isGameLoading else { return }
        
        isGameLoading = true
        defer { isGameLoading = false }
        
        guard let url = URL(string: "\(Endpoint.basePath)game") else {
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
            
            gameServices = try BigAssDecoder.decode([BillingGameServiceSummary].self, from: data)
        } catch {
            SystemAlert.error("Error loading game services", subtitle: error.localizedDescription)
        }
    }
    
    func fetchMyBotServices() async {
        guard !isBotLoading else { return }
        
        isBotLoading = true
        defer { isBotLoading = false }
        
        guard let url = URL(string: "\(Endpoint.basePath)bot") else {
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
            
            botServices = try BigAssDecoder.decode([BillingBotServiceSummary].self, from: data)
        } catch {
            SystemAlert.error("Error loading bot services", subtitle: error.localizedDescription)
        }
    }
}
