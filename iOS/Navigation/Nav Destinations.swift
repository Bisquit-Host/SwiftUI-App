enum NavDestinations: Hashable {
#if !os(watchOS)
    case toAuth
#endif
    
    //#if os(watchOS)
    //    case toServerList(selectedServer: Int)
    case toServerList
    
#if !os(macOS)
    case toPanel(_ id: String)
#endif
    
#if !os(visionOS)
    case toMap
    case toFileManager(_ id: String, root: String)
#endif
    
#if os(watchOS)
    case toSettings
#endif
}
