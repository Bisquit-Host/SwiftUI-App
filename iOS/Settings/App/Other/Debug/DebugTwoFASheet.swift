import SwiftUI

enum DebugTwoFASheet: String, CaseIterable, Identifiable {
    case billingSetup, billingLogin
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .billingSetup: "Billing: Set up 2FA"
        case .billingLogin: "Billing: Verify 2FA login"
        }
    }
}
