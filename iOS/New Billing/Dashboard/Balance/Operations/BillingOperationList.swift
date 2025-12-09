import SwiftUI

struct BillingOperationList: View {
    @Environment(SheetTopupVM.self) private var vm
    
    var body: some View {
        if vm.isLoading && vm.operations.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            
        } else if vm.operations.isEmpty {
            ContentUnavailableView("No operations yet", systemImage: "creditcard")
                .listRowBackground(Color.clear)
            
        } else {
            BillingSectionCard("Operations") {
                ForEach(Array(vm.operations.enumerated()), id: \.element.id) { index, operation in
                    BillingOperationRow(operation)
                    
                    if index < vm.operations.count - 1 {
                        Divider()
                    }
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
        }
    }
}
