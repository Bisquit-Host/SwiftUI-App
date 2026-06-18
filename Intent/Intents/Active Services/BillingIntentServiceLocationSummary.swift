#if os(iOS)
nonisolated struct BillingIntentServiceLocationSummary: Decodable, Sendable {
    let name: String
    let flagUrl: String?
}
#endif
