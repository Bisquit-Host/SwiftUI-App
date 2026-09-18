import SwiftUI

enum DebugTwoFASheet: String, CaseIterable, Identifiable {
    case calagopusEnable, calagopusDisable, billingSetup, billingLogin

    var id: Self { self }

    var title: String {
        switch self {
        case .calagopusEnable: "Calagopus: Enable 2FA"
        case .calagopusDisable: "Calagopus: Disable 2FA"
        case .billingSetup: "Billing: Set up 2FA"
        case .billingLogin: "Billing: Verify 2FA login"
        }
    }
}
