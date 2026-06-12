#if os(iOS)
import AppIntents
import PteroNet

struct OpenBalanceTopupIntent: OpenIntent, TargetContentProvidingIntent {
    static let title: LocalizedStringResource = "Top Up Balance"
    static let description = IntentDescription("Opens the balance top-up sheet with a selected payment provider")
    
    @Parameter(title: "Payment provider", requestValueDialog: "Which payment provider?")
    var target: TopupPaymentProviderEntity
}

struct TopupPaymentProviderEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Payment Provider")
    static let defaultQuery = TopupPaymentProviderQuery()
    
    let id: String
    let name: String
    let currencyCode: String?
    
    var displayRepresentation: DisplayRepresentation {
        if let currencyCode {
            DisplayRepresentation(title: "\(name)", subtitle: "\(currencyCode)")
        } else {
            DisplayRepresentation(title: "\(name)")
        }
    }
}

struct TopupPaymentProviderQuery: EntityQuery {
    func entities(for identifiers: [TopupPaymentProviderEntity.ID]) async throws -> [TopupPaymentProviderEntity] {
        let providers = await fetchProviders()
        return identifiers.compactMap { identifier in
            providers.first { $0.id == identifier } ?? fallbackProvider(for: identifier)
        }
    }
    
    func suggestedEntities() async throws -> [TopupPaymentProviderEntity] {
        await fetchProviders()
    }
    
    private func fetchProviders() async -> [TopupPaymentProviderEntity] {
        guard let accessToken = billingAccessToken() else {
            return [.appStore]
        }
        
        guard let providers = await fetchPaymentProviders(accessToken: accessToken) else {
            return [.appStore]
        }
        
        return providers.map(TopupPaymentProviderEntity.init) + [.appStore]
    }
    
    private func fallbackProvider(for id: String) -> TopupPaymentProviderEntity {
        if id == TopupPaymentProviderEntity.appStore.id {
            return .appStore
        }
        
        return TopupPaymentProviderEntity(id: id, name: id, currencyCode: nil)
    }
    
    private func fetchPaymentProviders(accessToken: String) async -> [TopupPaymentGatewayInfo]? {
        guard let url = URL(string: "https://api.bisquit.host/finances/payment-gateways") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 204 {
                    return []
                }
                
                guard response.statusCode < 400 else {
                    return nil
                }
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(TopupPaymentGatewaysResponse.self, from: data).gateways
        } catch {
            return nil
        }
    }
    
    private func billingAccessToken() -> String? {
        if let sessionToken = Keychain.load(key: "session_token"), !sessionToken.isEmpty {
            return sessionToken
        }
        
        if let legacyAccessToken = Keychain.load(key: "access_token"), !legacyAccessToken.isEmpty {
            return legacyAccessToken
        }
        
        return nil
    }
}

struct BillingAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenBalanceTopupIntent(),
            phrases: [
                "Top up my balance in \(.applicationName)",
                "Add money in \(.applicationName)",
                "Open balance top up in \(.applicationName)"
            ],
            shortTitle: "Top Up Balance",
            systemImageName: "creditcard.fill"
        )
    }
}

private extension TopupPaymentProviderEntity {
    static let appStore = TopupPaymentProviderEntity(id: "app_store", name: "App Store", currencyCode: nil)
    
    init(_ gateway: TopupPaymentGatewayInfo) {
        id = gateway.id
        name = Self.fallbackName(for: gateway.id, name: gateway.name)
        currencyCode = gateway.resolvedChargeCurrency ?? gateway.defaultChargeCurrency
    }
    
    static func fallbackName(for id: String, name: String?) -> String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmed, !trimmed.isEmpty {
            return trimmed
        }
        
        switch id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "tbank", "t-bank": return "T-Bank"
        case "stripe": return "Stripe"
        default: return id
        }
    }
}

nonisolated private struct TopupPaymentGatewaysResponse: Decodable {
    let gateways: [TopupPaymentGatewayInfo]
}

nonisolated private struct TopupPaymentGatewayInfo: Decodable {
    let id: String
    let name: String?
    let defaultChargeCurrency: String
    let resolvedChargeCurrency: String?
}
#endif
