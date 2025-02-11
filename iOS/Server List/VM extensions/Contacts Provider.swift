import Foundation
import PteroNet

extension ServerListVM {
    func fetchUniqueUsers() {
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
}
