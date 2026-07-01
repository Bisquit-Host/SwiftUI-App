import SwiftUI
import Calagopus

@Observable
final class StartPageVM {
    private let apiKeyPrefixLength = 16
    
    var apiKey = ""
    
    var alertTitle = "Error 0"
    var errorDescription = ""
    var errorCode = "0"
    
    var alertInvalid = false
    var isActivse = false
    var trigger = false
    
    var sheetGuide = false
    var sheetCloudKeys = false
    
    func fetchAccountDetails(onSuccess: @escaping () -> Void) async {
        guard !apiKeyIsPrefix else {
            showAPIKeyPrefixWarning()
            return
        }
        
        do {
            _ = try await CalagopusClient(apiKey: apiKey).account()
            Keychain.save(apiKey, forKey: "selectedApiKey")
            onSuccess()
        } catch {
            if case let CalagopusError.httpStatus(_, _, apiError) = error,
               let code = apiError?.firstDetail?.code {
                errorCode = code
            }
            
            alertTitle = "Error \(errorCode)"
            trigger.toggle()
            SystemAlert.error(error)
            
            try? await Task.sleep(for: .seconds(0.5))
            self.alertInvalid = true
        }
    }
    
    var apiKeyIsPrefix: Bool {
        apiKey.count == apiKeyPrefixLength
    }
    
    func showAPIKeyPrefixWarning() {
        alertTitle = "API key prefix"
        errorCode = "0"
        errorDescription = "You have entered the prefix of an API key. Recreate it or copy the whole API key"
        alertInvalid = true
    }
}
