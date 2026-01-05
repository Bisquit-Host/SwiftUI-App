import ScrechKit
import CoreImage.CIFilterBuiltins
import PteroNet

@Observable
final class AccountVM {
    private(set) var account: AccountAttributes? = nil
    private(set) var qrCodeURL = ""
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
            qrCodeURL = try await twoFaDetailtsAPI()
            twoFaEnabled = false
            
        } catch TwoFAError.alreadyEnabled {
            twoFaEnabled = true
            
        } catch {
            SystemAlert.error(error)
            print("2FA details error:", error.localizedDescription)
        }
    }
    
    func enable2Fa(_ code: String, password: String, onSuccess: @escaping () -> ()) async {
        do {
            let tokens = try await twoFaEnableAPI(code, password: password)
            
            Pasteboard.copy(tokens.tokens.description)
            
            onSuccess()
            SystemAlert.copied("Recovery codes copied")
            
            await twoFaDetails()
        } catch {
            print("Error enabling 2FA")
            SystemAlert.error(error)
        }
    }
    
    func disable2Fa(_ password: String, onSuccess: @escaping () -> ()) async {
        do {
            try await twoFaDisableAPI(password)
            
            onSuccess()
            
            await twoFaDetails()
        } catch {
            print("Error disabling 2FA")
            SystemAlert.error(error)
        }
    }
}
