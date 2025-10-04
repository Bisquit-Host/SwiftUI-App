import PteroNet

enum NavDestinations: Hashable {
#if !os(macOS)
    case toServerList
#endif
#if os(iOS)
    case toSettings
#endif
    
#if os(visionOS)
    case toPanel(_ server: ServerAttributes)
#elseif !os(macOS)
    case toPanel(_ server: String)
#endif
    
#if !os(visionOS)
    case toFileManager(_ id: String, root: String)
#endif
    
#if os(watchOS)
    case toSettings
#endif
}
