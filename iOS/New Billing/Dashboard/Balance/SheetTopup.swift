import SwiftUI

struct SheetTopup: View {
    @EnvironmentObject private var store: ValueStore
    @State private var vm = SheetTopupVM()
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
    }
    
    var body: some View {
        List {
            Section {
                Text("Balance \(user.balance, specifier: "%.2f")")
                Text("Bonus balance \(user.bonusBalance, specifier: "%.2f")")
                Text("Total balance \(user.totalBalance, specifier: "%.2f")")
            }
            
            Section("Operations") {
                if vm.isLoading && vm.operations.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                    
                } else if vm.operations.isEmpty {
                    ContentUnavailableView("No operations yet", systemImage: "creditcard")
                        .listRowBackground(Color.clear)
                    
                } else {
                    ForEach(vm.operations) { operation in
                        BillingOperationRow(operation)
                    }
                }
            }
        }
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

#Preview {
    SheetTopup(.preview)
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
