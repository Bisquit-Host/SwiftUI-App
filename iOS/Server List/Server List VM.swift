import ScrechKit
import PteroNet

struct ItunesAppInfo: Decodable {
    let results: [ItunesAppInfoResult]
}

struct ItunesAppInfoResult: Decodable {
    let version: String
}

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
    var alertUpdate = false
    
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
    
    func checkForUpdates() async {
        let decoder = JSONDecoder()
        var appStoreVersion = "0"
        
        guard
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=host.bisquit.Bisquit-Host")
        else {
            return
        }
        
        let request = URLRequest(url: url)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try decoder.decode(ItunesAppInfo.self, from: data)
            appStoreVersion = decoded.results.first?.version ?? "0"
        } catch {
            return
        }
        
        if currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending {
            print("Update available: \(currentVersion) -> \(appStoreVersion)")
            self.alertUpdate = true
        } else {
            print("The app is up to date")
        }
    }
    
    func fetchServers(_ isAdmin: Bool) {
        serverListAPI(isAdmin) { result in
            switch result {
            case .success(let model):
                guard let model else {
                    return
                }
                
                let loadedServers = model.data.map(\.attributes)
                let totalPages = model.meta.pagination.totalPages
                
                if totalPages > 1 {
                    self.fetchAllPages(isAdmin, totalPages: totalPages, currentServers: loadedServers)
                } else {
                    withAnimation {
                        self.servers = loadedServers
                    }
                    
                    self.saveServers()
                }
                
                Task {
                    await self.submitScore()
                }
                
#if canImport(ContactProvider)
                if ValueStore().contactsProviderEnabled {
                    self.fetchUniqueUsers()
                }
#endif
                
#if canImport(CoreSpotlight) && !os(tvOS)
                self.indexItems(self.servers)
#endif
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    private func fetchAllPages(_ isAdmin: Bool, totalPages: Int, currentServers: [ServerAttributes]) {
        var loadedServers = currentServers
        let group = DispatchGroup()
        
        for page in 2...totalPages {
            group.enter()
            
            serverListAPI(isAdmin, page: page) { result in
                switch result {
                case .success(let model):
                    if let model {
                        let servers = model.data.map(\.attributes)
                        loadedServers.append(contentsOf: servers)
                    }
                    
                case .failure(let error):
                    SystemAlert.error(error)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            withAnimation {
                self.servers = loadedServers
            }
            
            self.saveServers()
        }
    }
}
