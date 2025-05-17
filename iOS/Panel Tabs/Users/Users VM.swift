import ScrechKit
import PteroNet

@Observable
final class UsersVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var users: [UserAttributes] = []
    private(set) var permissions: PermissionAttributes?
    
    var newUserPermissions: [String] = []
    var allPermsTrigger = false
    var sheetInvitation = false
    
    var userPermissionsDict: [String: Bool] {
        var dict: [String: Bool] = [:]
        
        if let permissions = self.permissions {
            permissions.permissions.forEach { key, permission in
                permission.keys.keys.forEach { subKey in
                    let fullKey = "\(key).\(subKey)"
                    
                    dict[fullKey] = false
                }
            }
        }
        
        return dict
    }
    
    var chunkedPermissions: [String: [String]] {
        var dict = [String: [String]]()
        
        for permission in userPermissionsDict.keys.sorted() {
            let components = permission.split(separator: ".").map(String.init)
            
            if components.count > 1 {
                let type = components[0]
                dict[type, default: []].append(permission)
            }
        }
        
        return dict
    }
    
    func createUser(_ email: String, onSuccess: @escaping () -> ()) {
        userCreateAPI(id, email: email, permissions: newUserPermissions) { result in
            switch result {
            case .success(let model):
                if let user = model?.attributes {
                    self.users.append(user)
                }
                
                onSuccess()
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func updateUser(_ userId: String, permissions: [String], onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        userUpdateAPI(id, userId: userId, permissions: permissions) { result in
            switch result {
            case .success:
                onSuccess()
                
            case .failure(let error):
                SystemAlert.error(error)
                onError()
            }
        }
    }
    
    func userDetails(_ user: Binding<UserAttributes>) {
        userDetailsAPI(id, userId: user.wrappedValue.uuid) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    user.wrappedValue = model
                }
                
            case .failure(let error):
                SystemAlert.error(error)
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
                SystemAlert.error(error)
            }
        }
    }
    
    func fetchUsers(_ prefetch: Bool = false) {
        userListAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    self.users = model.map(\.attributes)
                    
                    if !prefetch {
                        self.prefetchUserImages()
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func delete(_ uuid: String) {
        userDeleteAPI(id, uuid: uuid) { result in
            switch result {
            case .success:
                self.fetchUsers()
                
            case .failure(let error):
                self.fetchUsers()
                SystemAlert.error(error)
            }
        }
    }
    
    private func prefetchUserImages() {
        let uniqueImages = Array(Set(self.users.compactMap { user in
            if let url = URL(string: user.image) {
                return url
            }
            
            return nil
        }))
        
        prefetchImages(uniqueImages)
    }
}
