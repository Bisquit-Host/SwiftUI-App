enum NavDestinations: Hashable {
    case toServerList
    
#if !os(macOS)
    case toPanel(_ id: String)
#endif
    
#if !os(visionOS)
    case toMap,
         toFileManager(_ id: String, root: String)
#endif
    
#if os(watchOS)
    case toSettings
#endif
}
