#if os(iOS)
nonisolated struct BillingIntentServicePackageSummary: Decodable, Sendable {
    let name: String
    let bonusBalanceAllowed: Bool?
    let windowsAllowed: Bool?
}
#endif
