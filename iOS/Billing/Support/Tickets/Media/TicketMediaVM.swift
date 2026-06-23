import SwiftUI
import BisquitoNet
import Calagopus

@Observable
final class TicketMediaVM {
    var image: Image?
    var isLoading = true
    
    func loadMedia(mediaPath: String) async {
        guard let accessToken = accessToken() else { return }
        
        do {
            guard let data = try await loadTicketMediaAPI(mediaPath: mediaPath, accessToken: accessToken, onBillingError: SystemAlert.error) else {
                isLoading = false
                return
            }
            
            if let uiImage = UIImage(data: data) {
                image = Image(uiImage: uiImage)
            } else {
                Logger().error("Unsupported media")
            }
        } catch {
            Logger().error("\(error)")
        }
        
        isLoading = false
    }
}
