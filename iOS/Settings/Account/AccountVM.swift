import SwiftUI
import CoreImage.CIFilterBuiltins
import PteroNet

@Observable
final class AccountVM {
    private(set) var account: AccountAttributes? = nil
    private(set) var qrCodeUrl = ""
    private(set) var twoFaEnabled: Bool?
    
    func fetch() async {
        do {
            account = try await accountDetailsAPI()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func twoFaDetails() async {
        do {
            qrCodeUrl = try await twoFaDetailtsAPI(printResponse: true)
            twoFaEnabled = false
            
        } catch TwoFAError.alreadyEnabled {
            twoFaEnabled = true
            
        } catch {
            SystemAlert.error(error)
            print("2FA details error:", error.localizedDescription)
        }
    }
    
    func enable2Fa(_ code: String, onSuccess: @escaping () -> ()) async {
        do {
            let tokens = try await twoFaEnableAPI(code)
            print(tokens.tokens)
#warning("Finish")
            onSuccess()
        } catch {
            print("Error enabling 2FA", error.localizedDescription)
            SystemAlert.error(error)
        }
    }
    
    func disable2Fa(_ password: String, onSuccess: @escaping () -> ()) async {
        do {
            try await twoFaDisableAPI(password)
            onSuccess()
        } catch {
            print("Error disabling 2FA", error.localizedDescription)
            SystemAlert.error(error)
        }
    }
}
