import ScrechKit
import PteroNet

@Observable
final class UsersVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var users: [UserListData] = []
    var permissions: Permissions?
    
    func fetchPermissions() {
        permissionListAPI { result in
            switch result {
            case .success(let model):
                if let model {
                    self.permissions = model
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func fetchUsers() {
        getUserListAPI(id) { result in
            switch result {
            case .success(let model):
                if let model {
                    self.users = model.data
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func delete(_ uuid: String) {
        deleteUser(id, uuid: uuid) { result in
            switch result {
            case .success:
                delay {
                    self.fetchUsers()
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
