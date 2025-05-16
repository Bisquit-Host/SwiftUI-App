import PteroNet

enum NavDestinations: Hashable {
    case toServerList
    
#if os(visionOS)
    case toPanel(_ server: ServerAttributes)
#elseif !os(macOS)
    case toPanel(_ server: String)
#endif
    
#if !os(visionOS)
    case toMap,
         toFileManager(_ id: String, root: String)
#endif
    
#if os(watchOS)
    case toSettings
#endif
}
