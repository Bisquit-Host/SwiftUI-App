import SwiftUI

struct Billing2FARetryButton: View {
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
    Billing2FARetryButton()
        .darkSchemePreferred()
        .environment(Billing2FAVM())
}
