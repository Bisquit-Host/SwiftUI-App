enum NavDestinations: Hashable {
    case toAuth
    
//#if os(watchOS)
//    case toServerList(selectedServer: Int)
    case toServerList
    
    case toPanel(_ id: String)
    
#if !os(xrOS)
    case toMap
    case toFileManager(_ id: String, path: String)
#endif
    
#if os(watchOS)
    case toSettings
#endif
}
