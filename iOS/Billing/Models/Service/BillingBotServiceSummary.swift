import Foundation

struct BillingBotServiceSummary: Decodable, Identifiable, Equatable {
    let id: Int
    let name: String
    let price: Double
    let autorenew: Bool
    let state: BillingServiceState
    let allowSuspend: Bool
    let allowDelete: Bool
    let createdAt: Date?
    let expiresAt: Date?
    let packageId: Int
    let packageName: String
    let locationId: Int
    let locationName: String
    let locationFlagUrl: String?
    let locationInfo: ServiceLocationSummary
    let packageInfo: ServiceSummaryPackage
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, autorenew, state, allowSuspend, allowDelete, createdAt, expiresAt, packageId, packageName, locationId, locationName, locationFlagUrl, locationInfo = "location", packageInfo = "package"
    }
}
