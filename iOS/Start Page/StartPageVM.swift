import SwiftUI
import Calagopus

@Observable
final class StartPageVM {
    var apiKey = ""
    
    var errorDescription = ""
    var errorCode = "0"
    
    var alertInvalid = false
    var isActive = false
    var trigger = false
    
    var sheetGuide = false
    var sheetCloudKeys = false
    
    func fetchAccountDetails(onSuccess: @escaping () -> Void) async {
        Keychain.save(apiKey, forKey: "selectedApiKey")
        
        do {
            _ = try await CalagopusClient(baseURL: CalagopusEndpointDefaults.currentBaseURL, apiKey: apiKey).account()
            onSuccess()
        } catch {
            if case let CalagopusError.httpStatus(_, _, apiError) = error,
               let code = apiError?.firstDetail?.code {
                errorCode = code
            }
            
            trigger.toggle()
            SystemAlert.error(error)
            
            try? await Task.sleep(for: .seconds(0.5))
            self.alertInvalid = true
        }
    }
}
