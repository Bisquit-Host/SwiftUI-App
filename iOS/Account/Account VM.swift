import SwiftUI
import CoreImage.CIFilterBuiltins
import PteroNet

@Observable
final class AccountVM {
    var account: AccountAttributes? = nil
    var qrCodeUrl = ""
    var twoFaEnabled = false
    
    func fetch() {
        accountDetailsAPI { [self] result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    account = model
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func twoFaDetails() {
        twoFaDetailtsAPI { [self] result in
            switch result {
            case .success(let model):
                twoFaEnabled = false
                
                if let model = model?.data.imageUrlData {
                    qrCodeUrl = model
                }
                
            case .failure(let error):
                guard
                    let error = error as? PterError,
                    error.status == "400"
                else {
                    SystemAlert.error(error)
                    return
                }
                
                twoFaEnabled = true
            }
        }
    }
    
    func enable2Fa(_ code: String, onSuccess: @escaping () -> ()) {
        twoFaEnableAPI(code) { result in
            switch result {
            case .success(let model):
                if let tokens = model?.attributes.tokens {
                    print(tokens)
#warning("FINISHSHSHHSHS")
                    onSuccess()
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func disable2Fa(_ code: String, onSuccess: @escaping () -> ()) {
        twoFaDisableAPI(code) { result in
            switch result {
            case .success(let model):
                print(model)
                onSuccess()
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
