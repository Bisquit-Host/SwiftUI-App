import ScrechKit
import StoreKit
import OSLog

struct TopupAppStoreProductView: View {
    @State private var product: Product?
    @State private var isLoading = false
    @State private var isPurchasing = false
    @State private var loadFailed = false
    
    private let productID = "host.bisquit.topup.10eur"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let product {
                Text(product.displayName)
                    .headline()
                
                Text(product.description)
                    .footnote()
                    .secondary()
                
                Button("Top up \(product.displayPrice)", action: purchase)
                    .buttonStyle(.glassProminent)
                    .disabled(isPurchasing)
                    .padding(.top)
                
            } else if isLoading {
                ProgressView()
                
            } else if loadFailed {
                ContentUnavailableView("Product unavailable", systemImage: "cart.badge.questionmark")
            }
        }
        .task {
            await loadProduct()
        }
    }
    
    private func loadProduct() async {
        guard product == nil, !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            product = try await Product.products(for: [productID]).first
            loadFailed = product == nil
        } catch is CancellationError {
            return
        } catch {
            loadFailed = true
            Logger().error("Failed to load App Store topup product: \(error.localizedDescription)")
        }
    }
    
    private func purchase() {
        guard let product else { return }
        
        Task {
            await purchase(product)
        }
    }
    
    private func purchase(_ product: Product) async {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(.verified(let transaction)):
                await transaction.finish()
                
            case .success(.unverified):
                SystemAlert.error("Purchase couldn't be verified")
                
            case .pending, .userCancelled:
                break
                
            @unknown default:
                break
            }
        } catch is CancellationError {
            return
        } catch {
            SystemAlert.error("Purchase failed")
            Logger().error("Failed to purchase App Store topup product: \(error.localizedDescription)")
        }
    }
}
