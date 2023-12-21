import ScrechKit
import PteroNet

@Observable
final class ServerListVM {
    // MARK: - PteroNet
    var servers: [ServerAttributes] = []
    var apiKey = Keychain.load(key: "selectedApiKey") ?? ""
    
    // MARK: - Sheets / Alerts
    var alertError = false
    var sheetGuide = false
    var sheetKeyStorage = false
    var sheetDiscover = false
    
    // MARK: - Filter/Search
    var searchField = ""
    var filterBySuspended = false
    var displayedNode: Node = .all
    
    var keys: [String] = []
    var footerHidden = true
    
    var filteredServers: [ServerAttributes] {
        servers.filter { server in
            let prompt = searchField.lowercased()
            let matchesSearch = searchField.isEmpty || server.name.lowercased().contains(prompt) || server.description.lowercased().contains(prompt)
            let matchesNode = displayedNode == .all || server.node == displayedNode.rawValue
            let matchesSuspended = !filterBySuspended || server.isSuspended
            
            return matchesSearch && matchesNode && matchesSuspended
        }
    }
    
    func switchFooter() {
        footerHidden = false
        
        delay(3) {
            self.footerHidden = true
        }
    }
    
    func fetchServers(_ isAdmin: Bool) {
        getServerListAPI(isAdmin) { result in
            switch result {
            case .success(let model):
                if let model {
                    var loadedServers = model.data.map {
                        $0.attributes
                    }
                    
                    let totalPages = model.meta.pagination.totalPages
                    
                    if totalPages > 1 {
                        let group = DispatchGroup()
                        
                        for page in 2...totalPages {
                            group.enter()
                            
                            getServerListAPI(isAdmin, page: page) { result in
                                switch result {
                                case .success(let model):
                                    if let model = model?.data {
                                        let servers = model.map {
                                            $0.attributes
                                        }
                                        
                                        loadedServers.append(contentsOf: servers)
                                    }
                                    
                                case .failure(let error):
                                    networkCallError(#function, error)
                                }
                                
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
                            withAnimation {
                                self.servers = loadedServers
                            }
                        }
                    } else {
                        withAnimation {
                            self.servers = loadedServers
                        }
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
