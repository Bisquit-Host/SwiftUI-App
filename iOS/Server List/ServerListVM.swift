import Foundation
import PteroNet

@Observable
final class ServerListVM {
    // MARK: - PteroNet
    private(set) var servers: [ServerAttributes] = []
    var apiKey = Keychain.load(key: "selectedApiKey") ?? ""
    
    // MARK: - Sheets / Alerts
    var sheetGuide = false
    var sheetKeyStorage = false
    var sheetDiscover = false
    var showBilling = false
    
    // MARK: - Filter/Search
    var searchField = ""
    var displayedNode = ""
    var filterBySuspended = false
    var filterByNotSuspended = false
    
    var selectedServer: ServerAttributes?
    
    var nodes: [String] {
        Array(Set(servers.map(\.node)))
            .sorted()
    }
    
    var hasSuspendedServers: Bool {
        servers.filter(\.isSuspended).count > 0
    }
    
    var hasMultipleNodes: Bool {
        nodes.count > 1
    }
    
    var showFilter: Bool {
        hasSuspendedServers || hasMultipleNodes
    }
    
    var hasFrozenServers: Bool {
        servers.contains {
            $0.isSuspended
        }
    }
    
    var filteredServers: [ServerAttributes] {
        servers.filter { server in
            let matchesName = searchField.isEmpty           || server.name.localizedStandardContains(searchField)
            let matchesDescription = searchField.isEmpty    || server.description.localizedStandardContains(searchField)
            let matchesNode = displayedNode.isEmpty         || server.node == displayedNode
            let matchesSuspended = !filterBySuspended       || server.isSuspended
            let matchesNotSuspended = !filterByNotSuspended || !server.isSuspended
            
            return matchesName && matchesDescription && matchesNode && matchesSuspended && matchesNotSuspended
        }
    }
    
    func loadServers() {
        if let loadedServers = UserDefaults.standard.serverAttributesArray(forKey: "servers") {
            servers = loadedServers
        }
    }
    
    private func saveServers() {
        UserDefaults.standard.setServerAttributesArray(servers, forKey: "servers")
    }
    
    func fetchServers(
        _ isAdmin: Bool,
        searchPrompt: String? = nil
    ) async {
        do {
            let model = try await serverListAPI(
                isAdmin,
                searchPrompt: searchPrompt,
                printResponse: true
            )
            
            servers = model.data.map(\.attributes)
            
            if searchPrompt == nil {
                saveServers()
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
