import Calagopus

extension ServerListVM {
    func fetchUniqueUsers() async {
        let ids = servers.map(\.id)
        
        var allUsers: [CalagopusServerSubuser] = []
        
        for id in ids {
            let users = await fetchUsers(id)
            
            for user in users {
                if !allUsers.contains(where: { $0.user.username == user.user.username }) {
                    allUsers.append(user)
                }
            }
        }
        
        await saveContacts(allUsers)
    }
    
    private func fetchUsers(_ id: String) async -> [CalagopusServerSubuser] {
        do {
            return try await CalagopusNet.client().subusers(server: id).data
        } catch {
            SystemAlert.error(error)
            return []
        }
    }
}
