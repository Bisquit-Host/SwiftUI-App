import SwiftUI
import BisquitoNet
import PteroNet

@Observable
final class TicketMediaVM {
    var image: Image?
    var isLoading = true
    
    func loadMedia(mediaPath: String) async {
        guard let accessToken = Keychain.load(key: "access_token") else {
            Logger().error("Access token not found in \(#function)")
            return
        }
        
        guard let url = buildURL(mediaPath) else {
            Logger().error("Invalid media URL")
            isLoading = false
            
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, res) = try await URLSession.shared.data(for: request)
            
            if decodeBillingError(data, with: res, onDecode: SystemAlert.error) {
                isLoading = false
                return
            }
            
            if let uiImage = UIImage(data: data) {
                let swiftUIImage = Image(uiImage: uiImage)
                
                image = swiftUIImage
                isLoading = false
            } else {
                Logger().error("Unsupported media")
                isLoading = false
            }
        } catch {
            Logger().error("\(error)")
            isLoading = false
        }
    }
    
    func buildURL(_ path: String) -> URL? {
        if let url = URL(string: path), url.scheme != nil {
            return url
        }
        
        let cleaned = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let filename = URL(fileURLWithPath: cleaned).lastPathComponent
        
        let baseURL = "https://test-api.bisquit.host"
        return URL(string: "\(baseURL)/media/tickets/\(filename)")
    }
}
