import SwiftUI

struct Billing2FASetup: View {
    @Environment(Billing2FAVM.self) private var vm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Billing2FASetupHeader()
            
            if vm.isLoading {
                HStack {
                    ProgressView()
                    Text("Preparing setup…")
                }
                
            } else if let setup = vm.setup {
                BillingTwoFASetupContent(setup)
                
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Unable to start 2FA setup")
                        .secondary()
                    
                    BillingTwoFARetryButton()
                }
            }
        }
        .navigationTitle("Set up 2FA")
        .navigationBarTitleDisplayMode(.inline)
        .environment(vm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .task {
            await vm.fetchSetup()
        }
    }
}
