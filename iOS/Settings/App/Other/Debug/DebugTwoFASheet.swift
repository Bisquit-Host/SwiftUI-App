import SwiftUI

enum DebugTwoFASheet: String, CaseIterable, Identifiable {
    case billingSetup, billingLogin
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .billingSetup: "Set up 2FA"
        case .billingLogin: "Verify 2FA login"
        }
    }
}
