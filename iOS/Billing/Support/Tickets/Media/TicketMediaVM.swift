import SwiftUI
import BisquitoNet
import PteroNet

@Observable
final class TicketMediaVM {
    var image: Image?
    var isLoading = true
    
    func loadMedia(mediaPath: String) async {
        guard let accessToken = Keychain.load(key: "access_token") else {
            print("Access token not found", #function)
            return
        }
        
        guard let url = buildURL(mediaPath) else {
            print("Invalid media URL")
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
                print("Unsupported media")
                isLoading = false
            }
        } catch {
            print(error.localizedDescription)
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
