import ScrechKit

struct BillingTwoFARetryButton: View {
    @Environment(Billing2FAVM.self) private var vm
    
    var body: some View {
        AsyncButton(action: vm.fetchSetup) {
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
