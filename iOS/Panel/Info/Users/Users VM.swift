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
    
    var permissionCount: Int {
        var count = 0
        
        if let permissions = permissions {
            for (_, permission) in permissions.permissions {
                count += permission.keys.count
            }
        }
        
        return count
    }
    
    func updateUser(_ userId: String, permissions: [String], onSuccess: @escaping () -> (), onError: @escaping () -> ()) {
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
