
enum NavDestinations: Hashable {
    case toServerList
    case toServerListParent
    
#if os(iOS)
    case toSettings
    case toBillingDashboard
#endif
    
    case toPanel(_ server: String)
    
#if !os(visionOS)
    case toFileManager(_ id: String, root: String)
#endif
    
#if os(watchOS)
    case toSettings
#endif
}
