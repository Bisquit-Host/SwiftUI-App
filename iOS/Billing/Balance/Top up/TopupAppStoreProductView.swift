import ScrechKit
import StoreKit

struct TopupAppStoreProductView: View {
    @State private var vm = TopupAppStoreProductVM()
    @Environment(\.purchase) private var purchaseAction
    
    let billingUserID: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let product = vm.product {
                Text(product.displayName)
                    .headline()
                
                Text(product.description)
                    .footnote()
                    .secondary()
                
                Button("Top up \(product.displayPrice)", action: purchase)
#if !os(visionOS)
                    .buttonStyle(.glassProminent)
#endif
                    .disabled(vm.isPurchasing)
                    .padding(.top)
                
            } else if vm.isLoading {
                ProgressView()
                
            } else if vm.loadFailed {
                ContentUnavailableView("Product unavailable", systemImage: "cart.badge.questionmark")
            }
        }
        .task {
            await vm.loadProduct()
        }
    }
    
    private func purchase() {
        Task {
            await vm.purchase(billingUserID: billingUserID) { product, options in
#if os(visionOS)
                try await purchaseAction(product, options: options)
#else
                try await product.purchase(options: options)
#endif
            }
        }
    }
}
