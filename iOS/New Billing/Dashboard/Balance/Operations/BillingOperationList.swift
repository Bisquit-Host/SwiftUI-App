import SwiftUI

struct BillingOperationList: View {
    let isLoading: Bool
    let operations: [BillingOperation]
    
    var body: some View {
        if isLoading && operations.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            
        } else if operations.isEmpty {
            ContentUnavailableView("No operations yet", systemImage: "creditcard")
                .listRowBackground(Color.clear)
            
        } else {
            BillingSectionCard("Operations") {
                ForEach(Array(operations.enumerated()), id: \.element.id) { index, operation in
                    BillingOperationRow(operation)
                    
                    if index < operations.count - 1 {
                        Divider()
                    }
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
        }
    }
}
