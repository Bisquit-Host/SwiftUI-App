import ScrechKit
import CoreImage.CIFilterBuiltins
import Calagopus

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
            SystemAlert.error("2FA details fetch failed", subtitle: error.localizedDescription)
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
            SystemAlert.error("Error enabling 2FA", subtitle: error.localizedDescription)
        }
    }
    
    func disable2Fa(_ password: String, onSuccess: @escaping () -> ()) async {
        do {
            try await twoFaDisableAPI(password)
            onSuccess()
            
            await twoFaDetails()
        } catch {
            SystemAlert.error("Error disabling 2FA", subtitle: error.localizedDescription)
        }
    }
}
