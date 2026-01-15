import PteroNet
@preconcurrency import CoreSpotlight

extension ServerListVM {
#if canImport(CoreSpotlight)
    func indexItems(_ servers: [ServerAttributes]) {
        CSSearchableIndex.default().deleteAllSearchableItems()
        
        let searchableItems = servers.map { server -> CSSearchableItem in
            let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
            attributeSet.title = server.name
            attributeSet.contentDescription = server.description
            attributeSet.identifier = server.id
            
            return CSSearchableItem(
                uniqueIdentifier: server.id,
                domainIdentifier: "host.bisquit.Bisquit-Host",
                attributeSet: attributeSet
            )
        }
        
        let identifiers = servers.map(\.id)
        
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: identifiers) { error in
            guard error == nil else {
                Logger().error("Error removing items from Spotlight: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
                guard error == nil else {
                    Logger().error("Spotlight indexing error: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
            }
        }
    }
#endif
}
