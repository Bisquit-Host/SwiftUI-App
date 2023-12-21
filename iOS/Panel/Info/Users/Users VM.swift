import ScrechKit
import PteroNet

@Observable
final class UsersVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var users: [UserListData] = []
    var permissions: PermissionAttributes?
    
    func updateUser(_ userId: String, permissions: [String], onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        updateUserAPI(id, userId: userId, permissions: permissions) { result in
            switch result {
            case .success:
                onSuccess()
                
            case .failure(let error):
                networkCallError(#function, error)
                onError()
            }
        }
    }
    
    func userDetails(_ user: Binding<UserListAttributes>) {
        userDetailsAPI(id, userId: user.wrappedValue.uuid) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    user.wrappedValue = model
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func fetchPermissions() {
        permissionListAPI { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
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
                if let model = model?.data {
                    self.users = model
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
