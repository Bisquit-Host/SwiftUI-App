import SwiftUI

struct SheetTopup: View {
    @EnvironmentObject private var store: ValueStore
    @State private var vm = SheetTopupVM()
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    var body: some View {
        ScrollView {
            BillingSectionCard("Balance") {
                BillingAccountRow("Main", icon: "creditcard.fill", tint: .blue, value: formatted(user.balance))
                BillingAccountRow("Bonus", icon: "sparkles", tint: .mint, value: formatted(user.bonusBalance))
                BillingAccountRow("Total", icon: "wallet.pass.fill", tint: .indigo, value: formatted(user.totalBalance))
            }
            
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
        .scenePadding()
        .task {
            await vm.fetchOperations(accessToken: store.testAccessToken)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
        }
    }
}

private extension SheetTopup {
    func formatted(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = user.currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSNumber) ?? "\(amount)"
    }
}

#Preview {
    SheetTopup(.preview)
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
