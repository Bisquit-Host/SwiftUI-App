import Foundation
import BisquitoNet
import PteroNet

@Observable
final class SheetTopupVM {
    var operations: [BillingOperation] = []
    var isLoading = false
    var isTopupLoading = false
    var isGiftCodeLoading = false
    
    func fetchOperations() async {
        guard let accessToken = accessToken() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        if let result = await fetchOperationsAPI(accessToken: accessToken) {
            operations = result
        } else {
            SystemAlert.error("Failed to fetch operations")
        }
    }
    
    func createTopup(amount: Int64, method: String?, currency: BillingCurrency) async -> URL? {
        guard let accessToken = accessToken() else { return nil }
        
        if amount < currency.minimumTopupAmount {
            SystemAlert.error("Amount too small")
            return nil
        }
        
        isTopupLoading = true
        defer { isTopupLoading = false }
        
        guard let topup = await createTopupAPI(accessToken: accessToken, amount: Double(amount), method: method) else {
            SystemAlert.error("Top up failed")
            return nil
        }
        
        guard let paymentURL = URL(string: topup.url) else {
            SystemAlert.error("Invalid payment URL")
            return nil
        }
        
        return paymentURL
    }
    
    func redeemGiftCode(_ code: String) async -> Int64? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            SystemAlert.error("Enter a gift code")
            return nil
        }
        
        guard let accessToken = accessToken() else { return nil }
        
        isGiftCodeLoading = true
        defer { isGiftCodeLoading = false }
        
        guard let giftCode = await redeemGiftCodeAPI(accessToken: accessToken, code: trimmed) else {
            SystemAlert.error("Gift code failed")
            return nil
        }
        
        return Int64(giftCode.bonusBalance.rounded())
    }
    
}
