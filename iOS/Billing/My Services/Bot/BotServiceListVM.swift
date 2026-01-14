import Foundation
import BisquitoNet
import PteroNet

@Observable
final class BotServiceListVM {
    var services: [BillingBotServiceSummary] = []
    var isLoading = false
    
    func loadServices() async {
        await fetch(path: "\(Endpoint.basePath)bot")
    }
    
    private func fetch(path: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: path) else {
            SystemAlert.error("Invalid URL")
            return
        }
        
        guard let accessToken = Keychain.load(key: "access_token") else {
            Logger().error("Access token not found in \(#function)")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                return
            }
            
            services = try BigAssDecoder.decode([BillingBotServiceSummary].self, from: data)
        } catch {
            SystemAlert.error("Error loading bot services", subtitle: error.localizedDescription)
        }
    }
}
