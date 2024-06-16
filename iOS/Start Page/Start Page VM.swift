import ScrechKit
import PteroNet

@Observable
final class StartPageVM {
    var apiKey = ""
    var accountName = ""
    var accountEmail = ""
    var errorDescription = ""
    var errorCode = 0
    var alertValid = false
    var alertInvalid = false
    var isActive = false
    var sheetSupport = false
    var sheetCloudKeys = false
    var sheetBrowsePlans = false
    var trigger = false
    
#if os(iOS)
    var showDemo = false
    var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
#endif
    
    func fetchAccountDetails() {
        Keychain.save(
            key: "selectedApiKey", 
            value: apiKey
        )
        
        accountDetailsAPI { result in
            main { [self] in
                switch result {
                case .success(let model):
                    if let model = model?.attributes {
                        validateKey(model)
                    }
                    
                case .failure(let error):
                    trigger.toggle()
                    networkCallError(#function, error)
                }
            }
        }
    }
    
    func validateKey(_ attributes: AccountAttributes) {
        self.accountName = attributes.firstName + " " + attributes.lastName
        self.accountEmail = attributes.email
        
        withAnimation {
            alertValid = true
        }
    }
}
