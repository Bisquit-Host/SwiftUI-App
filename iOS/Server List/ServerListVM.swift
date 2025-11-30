import Foundation
import PteroNet

@Observable
final class ServerListVM {
    // MARK: - PteroNet
    private(set) var servers: [ServerAttributes] = []
    var apiKey = Keychain.load(key: "selectedApiKey") ?? ""
    
    // MARK: - Sheets / Alerts
    var sheetGuide = false
    var sheetDiscover = false
    var showBilling = false
    
    // MARK: - Filter/Search
    var searchField = ""
    var displayedNode = ""
    var filterByNotSuspended = false
    
    var selectedServer: ServerAttributes?
    
    var hasSuspendedServers: Bool {
        servers.filter(\.isSuspended).count > 0
    }
    
    var hasFrozenServers: Bool {
        servers.contains {
            $0.isSuspended
        }
    }
    
    var filteredServers: [ServerAttributes] {
        servers.filter {
            let matchesName = searchField.isEmpty           || $0.name.localizedStandardContains(searchField)
            let matchesDescription = searchField.isEmpty    || $0.description.localizedStandardContains(searchField)
            let matchesNode = displayedNode.isEmpty         || $0.node == displayedNode
            let matchesNotSuspended = !filterByNotSuspended || !$0.isSuspended
            
            return matchesName && matchesDescription && matchesNode && matchesNotSuspended
        }
    }
    
    /// Loads server list array from UserDefaults
    func loadCachedServers() {
        if let loadedServers = UserDefaults.standard.serverAttributesArray(forKey: "servers") {
            servers = loadedServers
        }
    }
    
    /// Saves server list array to UserDefaults
    private func cacheServers() {
        UserDefaults.standard.setServerAttributesArray(servers, forKey: "servers")
    }
    
    func fetchServers(_ isAdmin: Bool = false, searchPrompt: String? = nil) async {
        do {
            let model = try await serverListAPI(isAdmin, searchPrompt: searchPrompt)
            servers = model.data.map(\.attributes)
            
            if searchPrompt == nil {
                cacheServers()
                await submitScore()
                
#if canImport(CoreSpotlight) && !os(tvOS)
                indexItems(servers)
#endif
                
#if canImport(ContactProvider)
                if ValueStore().contactsProviderEnabled {
                    await fetchUniqueUsers()
                }
#endif
            }
        } catch {
            SystemAlert.error(error)
        }
    }
}
