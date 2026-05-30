import SwiftUI

struct BillingTwoFARetryButton: View {
    @Environment(Billing2FAVM.self) private var vm
    
    var body: some View {
        Button {
            Task {
                await vm.fetchSetup()
            }
        } label: {
            if vm.isLoading {
                ProgressView()
            } else {
                Text("Retry")
            }
        }
    }
}

#Preview {
    BillingTwoFARetryButton()
        .darkSchemePreferred()
        .environment(Billing2FAVM())
}
