import Foundation
import BisquitoNet
import PteroNet

@Observable
final class VDSBillingVM {
    var services: [CloudServiceSummary] = []
    var isLoading = false
    
    func loadServices() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: "\(Endpoint.basePath)cloud") else {
            print("Invalid URL")
            return
        }
        
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                return
            }
            
            services = try BigAssDecoder.decode([CloudServiceSummary].self, from: data)
        } catch {
            SystemAlert.error(error.localizedDescription)
            print("Cloud services load failed:", error)
        }
    }
}
