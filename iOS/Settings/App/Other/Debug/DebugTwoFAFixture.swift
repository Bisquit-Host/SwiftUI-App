import Foundation
import BisquitoNet

enum DebugTwoFAFixture {
    static let setupURL = "otpauth://totp/Bisquit%20Debug:debug%40example.com?secret=JBSWY3DPEHPK3PXP&issuer=Bisquit%20Debug"

    static let billingSetup: Billing2FASetupResponse = {
        // The library response is Decodable and has no public initializer
        let json = """
        {"url":"\(setupURL)","accountName":"debug@example.com","secret":"JBSWY3DPEHPK3PXP"}
        """

        do {
            return try JSONDecoder().decode(Billing2FASetupResponse.self, from: Data(json.utf8))
        } catch {
            preconditionFailure("Invalid debug 2FA fixture: \(error)")
        }
    }()
}
