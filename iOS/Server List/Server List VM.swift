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
            let matchesSuspended = !filterBySuspended || server.attributes.is_suspended
            
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
                    var loaded_servers = model.data
                    let total_pages = model.meta.pagination.total_pages
                    
                    if total_pages > 1 {
                        let group = DispatchGroup()
                        
                        for page in 2...total_pages {
                            group.enter()
                            
                            getServerListAPI(isAdmin, page: page) { result in
                                switch result {
                                case .success(let model):
                                    if let model {
                                        loaded_servers.append(contentsOf: model.data)
                                    }
                                    
                                case .failure(let error):
                                    networkCallError(#function, error)
                                }
                                
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
                            withAnimation {
                                self.servers = loaded_servers
                            }
                        }
                    } else {
                        withAnimation {
                            self.servers = loaded_servers
                        }
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
