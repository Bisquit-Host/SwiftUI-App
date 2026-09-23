nonisolated struct ContactEmailSummary: Identifiable, Sendable {
    let id: String
    let fullName: String
    let emailAddresses: [String]
}
