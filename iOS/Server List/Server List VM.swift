import ScrechKit
import PteroNet

@Observable
final class ServerListVM {
    // MARK: - PteroNet
    var servers: [ServerListData] = []
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
    
    var filteredServers: [ServerListData] {
        servers.filter { server in
            let prompt = searchField.lowercased()
            let matchesSearch = searchField.isEmpty || server.attributes.name.lowercased().contains(prompt) || server.attributes.description.lowercased().contains(prompt)
            let matchesNode = displayedNode == .all || server.attributes.node == displayedNode.rawValue
            let matchesSuspended = !filterBySuspended || server.attributes.isSuspended
            
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
                    var loadedServers = model.data
                    let totalPages = model.meta.pagination.totalPages
                    
                    if totalPages > 1 {
                        let group = DispatchGroup()
                        
                        for page in 2...totalPages {
                            group.enter()
                            
                            getServerListAPI(isAdmin, page: page) { result in
                                switch result {
                                case .success(let model):
                                    if let model {
                                        loadedServers.append(contentsOf: model.data)
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
