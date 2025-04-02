import ScrechKit
import PteroNet

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
    var sheetBrowsePlans = false
    
    func fetchAccountDetails(onSuccess: @escaping () -> Void) {
        Keychain.save(
            key: "selectedApiKey",
            value: apiKey
        )
        
        accountDetailsAPI { result in
            main { [self] in
                switch result {
                case .success:
                    onSuccess()
                    
                case .failure(let error):
                    if let error = error as? PterError {
                        errorCode = error.code
                    }
                    
                    trigger.toggle()
                    
                    SystemAlert.error(error)
                    
                    askToDeleteKey()
                }
            }
        }
    }
    
    func askToDeleteKey() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.alertInvalid = true
        }
    }
}
