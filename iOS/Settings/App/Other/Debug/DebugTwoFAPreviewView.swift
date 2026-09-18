import SwiftUI

struct DebugTwoFAPreviewView: View {
    let sheet: DebugTwoFASheet

    @Environment(\.dismiss) private var dismiss
    @State private var accountVM = AccountVM(mockTwoFASetupURL: DebugTwoFAFixture.setupURL)
    @State private var billingVM = Billing2FAVM(mockSetup: DebugTwoFAFixture.billingSetup)
    @State private var dashboardVM = DashboardVM()
    @State private var code = ""
    @State private var isVerifying = false

    var body: some View {
        NavigationStack {
            Group {
                switch sheet {
                case .calagopusEnable:
                    Enable2FAView()
                case .billingSetup:
                    Billing2FASetup()
                case .billingLogin:
                    Login2FASheet(code: $code, isVerifying: $isVerifying) {
                        dismiss()
                    }
                    .scenePadding()
                case .calagopusDisable:
                    EmptyView()
                }
            }
            .navigationTitle(sheet.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
        .environment(accountVM)
        .environment(billingVM)
        .environment(dashboardVM)
    }
}
