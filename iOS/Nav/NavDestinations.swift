import Calagopus

enum NavDestinations: Hashable {
#if !os(macOS)
    case toServerList
    case toServerListParent
#endif
    
#if os(iOS)
    case toSettings
    case toBillingDashboard
#endif
    
#if !os(macOS)
    case toPanel(_ server: String)
#endif
    
#if !os(visionOS)
    case toFileManager(_ id: String, root: String)
#endif
    
#if os(watchOS)
    case toSettings
#endif
}
