#if os(iOS)
import Foundation
import AppIntents
import BisquitoNet

struct GetActiveServicesIntent: AppIntent {
    static let title: LocalizedStringResource = "Active Services"
    static let description = IntentDescription("Fetches all active services")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get active services")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let accessToken = BillingIntentAccessToken.load() else {
            throw ActiveServicesIntentError.notSignedIn
        }
        
        async let cloudServices = fetchActiveServices(.cloud, accessToken: accessToken)
        async let gameServices = fetchActiveServices(.game, accessToken: accessToken)
        async let botServices = fetchActiveServices(.bot, accessToken: accessToken)
        
        let services = try await cloudServices + gameServices + botServices
        
        guard !services.isEmpty else {
            return .result(value: "No active services found", dialog: "No active services found")
        }
        
        let summary = services.map(serviceSummary).joined(separator: "\n")
        let dialog = services.count == 1 ? "Here is your active service" : "Here are your active services"
        
        return .result(value: summary, dialog: "\(dialog):\n\(summary)")
    }
    
    nonisolated private func fetchActiveServices(_ kind: BillingIntentServiceKind, accessToken: String) async throws -> [(BillingIntentServiceKind, BillingIntentServiceSummary)] {
        let services = try await fetchServices(kind, accessToken: accessToken)
        
        return services
            .filter { $0.state == .active }
            .map { (kind, $0) }
    }
    
    nonisolated private func fetchServices(_ kind: BillingIntentServiceKind, accessToken: String) async throws -> [BillingIntentServiceSummary] {
        guard let services: [BillingIntentServiceSummary] = await fetchMyServicesAPI(
            endpointPath: kind.endpointPath,
            accessToken: accessToken,
            emptyResponse: []
        ) else {
            throw ActiveServicesIntentError.servicesUnavailable
        }
        
        return services
    }
    
    nonisolated private func serviceSummary(_ item: (BillingIntentServiceKind, BillingIntentServiceSummary)) -> String {
        let expiresAt = item.1.expiresAt.map {
            ", expires \($0.formatted(date: .abbreviated, time: .omitted))"
        } ?? ""
        
        return "\(item.0.title): \(item.1.name), \(item.1.packageName) in \(item.1.locationName)\(expiresAt)"
    }
}
#endif
