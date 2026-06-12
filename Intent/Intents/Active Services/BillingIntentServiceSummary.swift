#if os(iOS)
import Foundation

nonisolated struct BillingIntentServiceSummary: Decodable, Identifiable, Sendable {
    let id: Int
    let name: String
    let price: Int64
    let autorenew: Bool
    let state: BillingIntentServiceState
    let allowSuspend: Bool
    let allowDelete: Bool
    let createdAt: Date?
    let expiresAt: Date?
    let packageId: Int
    let packageName: String
    let locationId: Int
    let locationName: String
    let locationFlagUrl: String?
    let locationInfo: BillingIntentServiceLocationSummary
    let packageInfo: BillingIntentServicePackageSummary
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, packageId, packageName, locationId, locationName, locationFlagUrl, locationInfo = "location", packageInfo = "package"
    }
}
#endif
