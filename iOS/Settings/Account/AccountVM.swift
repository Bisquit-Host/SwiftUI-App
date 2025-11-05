import SwiftUI
import CoreImage.CIFilterBuiltins
import PteroNet

@Observable
final class AccountVM {
    private(set) var account: AccountAttributes? = nil
    private(set) var qrCodeUrl = ""
    private(set) var twoFaEnabled = false
    
    func fetch() async {
        do {
            account = try await accountDetailsAPI()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func twoFaDetails() async {
        twoFaEnabled = false
        
        do {
            qrCodeUrl = try await twoFaDetailtsAPI()
        } catch {
            if let error = error as? PterError, error.status == "400" {
                twoFaEnabled = true
            } else {
                SystemAlert.error(error)
            }
        }
    }
    
    func enable2Fa(_ code: String, onSuccess: @escaping () -> ()) async {
        do {
            let tokens = try await twoFaEnableAPI(code)
            print(tokens.tokens)
#warning("Finish")
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func disable2Fa(_ password: String, onSuccess: @escaping () -> ()) async {
        do {
            try await twoFaDisableAPI(password)
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
}
