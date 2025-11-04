import PteroNet

extension ServerListVM {
    func fetchUniqueUsers() async {
        let ids = servers.map(\.id)
        
        var allUsers: [UserAttributes] = []
        
        for id in ids {
            let users = await fetchUsers(id)
            
            for user in users {
                if !allUsers.contains(where: { $0.email == user.email }) {
                    allUsers.append(user)
                }
            }
        }
        
        await saveContacts(allUsers)
    }
    
    private func fetchUsers(_ id: String) async -> [UserAttributes] {
        do {
            return try await userListAPI(id)
        } catch {
            SystemAlert.error(error)
            return []
        }
    }
}
