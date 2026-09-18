import Foundation
import BisquitoNet

@Observable
final class Billing2FAVM {
    var setup: Billing2FASetupResponse?
    var isLoading = false
    var isEnabling = false
    var isDisabling = false
    var code = ""
    
    let isMock: Bool

    init(mockSetup: Billing2FASetupResponse? = nil) {
        setup = mockSetup
        isMock = mockSetup != nil
    }

    func fetchSetup() async {
        guard !isMock else { return }
        guard let accessToken = accessToken() else { return }
        
        isLoading = true
        defer { isLoading = false }
        setup = await billing2FASetupAPI(
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
    }
    
    func enable(code: String) async -> Bool {
        guard !isMock else { return true }
        guard let accessToken = accessToken() else { return false }
        
        isEnabling = true
        defer { isEnabling = false }
        return await enableBilling2FAAPI(
            code: code,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) != nil
    }
    
    func disable() async -> Bool {
        guard !isMock else { return true }
        guard let accessToken = accessToken() else { return false }
        
        isDisabling = true
        defer { isDisabling = false }
        return await disableBilling2FAAPI(
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) != nil
    }
}

extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
