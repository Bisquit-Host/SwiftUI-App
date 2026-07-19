import SwiftUI

struct BillingOperationList: View {
    @Environment(SheetTopupVM.self) private var vm
    
    var body: some View {
        if vm.isLoading && vm.operations.isEmpty {
            Section("Operations") {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            
        } else if vm.operations.isEmpty {
            Section("Operations") {
                ContentUnavailableView("No operations yet", systemImage: "creditcard")
            }
            
        } else {
            Section("Operations") {
                ForEach(vm.operations) {
                    BillingOperationCard($0)
                }
            }
        }
    }
}
