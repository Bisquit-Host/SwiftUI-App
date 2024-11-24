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
    var displayedNode = ""
    var filterBySuspended = false
    
    var keys: [String] = []
    
    var selectedServer: ServerAttributes?
    
    var filteredServers: [ServerAttributes] {
        servers.filter { server in
            let prompt = searchField.lowercased()
            let matchesSearch = searchField.isEmpty || server.name.lowercased().contains(prompt) || server.description.lowercased().contains(prompt)
            let matchesNode = displayedNode.isEmpty || server.node == displayedNode
            let matchesSuspended = !filterBySuspended || server.isSuspended
            
            return matchesSearch && matchesNode && matchesSuspended
        }
    }
    
#if os(iOS)
    private func fetchUniqueUsers() {
        let ids = servers.map(\.id)
        
        var allUsers: [UserAttributes] = []
        let dispatchGroup = DispatchGroup()
        let queue = DispatchQueue(label: "host.bisquit.uniqueUsersQueue")
        
        for id in ids {
            dispatchGroup.enter()
            
            fetchUsers(id) { users in
                guard let users else {
                    dispatchGroup.leave()
                    return
                }
                
                queue.async {
                    for user in users {
                        if !allUsers.contains(where: { $0.email == user.email }) {
                            allUsers.append(user)
                        }
                    }
                    
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let niggers = allUsers
            
            Task {
                await self.saveContacts(niggers)
            }
        }
    }
    
    private func fetchUsers(_ id: String, completion: @escaping ([UserAttributes]?) -> Void) {
        userListAPI(id) { result in
            switch result {
            case .success(let model):
                guard let model = model?.data else {
                    completion(nil)
                    return
                }
                
                let attributes = model.map(\.attributes)
                completion(attributes)
                
            case .failure(let error):
                SystemAlert.error(error)
                completion(nil)
            }
        }
    }
#endif
    
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
                }
                
#if os(iOS)
                if SettingsStorage().contactsProviderEnabled {
                    self.fetchUniqueUsers()
                }
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
                    if let model = model?.data {
                        let servers = model.map(\.attributes)
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
        }
    }
}
