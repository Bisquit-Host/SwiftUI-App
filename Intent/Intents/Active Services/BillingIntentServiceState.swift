#if os(iOS)
enum BillingIntentServiceState: String, Decodable, Sendable {
    case installing = "INSTALLING",
         active = "ACTIVE",
         suspended = "SUSPENDED",
         unsuspending = "UNSUSPENDING",
         reinstalling = "REINSTALLING",
         deleted = "DELETED"
}
#endif
