import SwiftUI
import BisquitoNet

struct Login2FASheetParent: View {
    @Binding var `2FACode`: String
    @Binding var pending2FAToken: String?
    var handleAuthResponse: @MainActor (BillingLoginResponse) async -> Void
    
    var body: some View {
        NavigationStack {
            Login2FASheet(`2FACode`: $2FACode, pending2FAToken: $pending2FAToken, handleAuthResponse: handleAuthResponse)
                .padding()
                .navigationTitle("Enter 2FA code")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
