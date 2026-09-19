import SwiftUI

struct DebugTwoFAPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    let sheet: DebugTwoFASheet
    
    @State private var billingVM = Billing2FAVM(mockSetup: DebugTwoFAFixture.billingSetup)
    @State private var dashboardVM = DashboardVM()
    @State private var code = ""
    @State private var isVerifying = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch sheet {
                case .billingSetup:
                    Billing2FASetup()
                    
                case .billingLogin:
                    Login2FASheet(code: $code, isVerifying: $isVerifying) {
                        dismiss()
                    }
                    .scenePadding()
                }
            }
        }
        .environment(billingVM)
        .environment(dashboardVM)
    }
}
