import SwiftUI
import StoreKit
import OSLog

@Observable
final class TopupAppStoreProductVM {
    private(set) var product: Product?
    private(set) var isLoading = false
    private(set) var isPurchasing = false
    private(set) var loadFailed = false

    private let productID = "host.bisquit.topup.10eur"

    func loadProduct() async {
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
    
    func purchase(
        billingUserID: Int,
        using purchaseAction: @MainActor (Product, Set<Product.PurchaseOption>) async throws -> Product.PurchaseResult
    ) async {
        guard let product else { return }
        guard !isPurchasing else { return }
        guard let appAccountToken = BillingAppAccountToken.token(for: billingUserID) else {
            SystemAlert.error("Invalid billing user")
            return
        }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await purchaseAction(product, [.appAccountToken(appAccountToken)])
            
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
