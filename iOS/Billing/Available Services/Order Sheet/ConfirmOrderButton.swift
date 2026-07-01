import SwiftUI
import OSLog

struct ConfirmOrderButton: View {
    @Environment(HostingPlanListVM.self) private var vm
    @Environment(NewOrderVM.self) private var orderVM
    @Environment(BiometryVM.self) private var biometry
    @EnvironmentObject private var store: ValueStore
    @Environment(\.dismiss) private var dismiss
    
    private let context: BillingPlanOrderContext
    private let name: String
    private let onSuccess: () -> Void
    
    init(_ context: BillingPlanOrderContext, onSuccess: @escaping () -> Void) {
        self.context = context
        self.name = context.plan.name
        self.onSuccess = onSuccess
    }
    
    @State private var alertPurchase = false
    
    private var isConfigurationIncomplete: Bool {
        context.category == .bot && orderVM.selectedEggID == 0
    }
    
    var body: some View {
        Button {
            alertPurchase = true
        } label: {
            if orderVM.isOrdering {
                ProgressView()
            } else {
                Text("Confirm purchase")
                    .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(.foreground)
        .disabled(orderVM.isOrdering || orderVM.isLoadingOptions || isConfigurationIncomplete)
        .alert("Confirm purchase", isPresented: $alertPurchase) {
            Button("Confirm", role: .confirm, action: confirmPurchase)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Purchase \(name) for \(orderVM.months) billing?")
        }
    }
    
    private func confirmPurchase() {
        Task {
            if store.useBiometry, await !biometry.authenticate() {
                SystemAlert.error("Biometry authentication failed")
                return
            }
            
            await order {
                onSuccess()
            }
        }
    }
    
    private func order(onSuccess: @escaping () -> Void) async {
        guard !orderVM.isOrdering else { return }
        
        orderVM.isOrdering = true
        defer { orderVM.isOrdering = false }
        
        let response = await vm.order(
            context: context,
            name: name,
            months: orderVM.months,
            osId: orderVM.selectedOSID == 0 ? nil : orderVM.selectedOSID,
            nestId: orderVM.selectedNestID == 0 ? nil : orderVM.selectedNestID,
            eggId: orderVM.selectedEggID == 0 ? nil : orderVM.selectedEggID
        )
        
        guard let response else { return }
        
        Logger().info("Order response: \(String(describing: response))")
        onSuccess()
        
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            dismiss()
        }
    }
}

//#Preview {
//    ConfirmOrderButton {}
//        .darkSchemePreferred()
//        .environment(NewOrderVM())
//        .environment(HostingPlanListVM())
//}
