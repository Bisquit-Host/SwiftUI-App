import Foundation
import Calagopus

@Observable
final class ServerListVM {
    // MARK: - CalagopusNet
    private(set) var servers: [CalagopusServer] = []
    var apiKey = Keychain.load(key: "selectedApiKey") ?? ""
    
    // MARK: - Sheets / Alerts
    var sheetGuide = false
    var sheetDiscover = false
    var showBilling = false
    
    // MARK: - Search
    var searchField = ""
    
    var selectedServer: CalagopusServer?
    
    var showSearch: Bool {
        filteredServers.count > 6
    }
    
    var hasSuspendedServers: Bool {
        servers.filter(\.isSuspended).count > 0
    }
    
    var hasFrozenServers: Bool {
        servers.contains {
            $0.isSuspended
        }
    }
    
    var filteredServers: [CalagopusServer] {
        servers.filter {
            let matchesName = searchField.isEmpty        || $0.name.localizedStandardContains(searchField)
            let matchesDescription = searchField.isEmpty || ($0.description ?? "").localizedStandardContains(searchField)
            
            return matchesName && matchesDescription
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
            let model = try await CalagopusNet.client().servers(search: searchPrompt, other: isAdmin)
            servers = model.data
            
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
