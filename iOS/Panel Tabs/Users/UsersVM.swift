import SwiftUI
import Calagopus

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
    
    func createUser(_ email: String, onSuccess: @escaping () -> ()) async {
        do {
            let user = try await userCreateAPI(id, email: email, permissions: newUserPermissions)
            users.append(user)
            
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func updateUser(_ userId: String, permissions: [String]) async throws {
        try await userUpdateAPI(id, userId: userId, permissions: permissions)
    }
    
    func userDetails(_ user: Binding<UserAttributes>) async {
        do {
            let userDetails = try await userDetailsAPI(id, userId: user.wrappedValue.uuid)
            user.wrappedValue = userDetails
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchPermissions() async {
        do {
            permissions = try await permissionListAPI()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchUsers(_ prefetch: Bool = false) async {
        do {
            self.users = try await userListAPI(id)
            
            if !prefetch {
                self.prefetchUserImages()
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func delete(_ uuid: String) async {
        do {
            try await userDeleteAPI(id, uuid: uuid)
        } catch {
            SystemAlert.error(error)
        }
        
        await fetchUsers()
    }
    
    private func prefetchUserImages() {
        let uniqueImages = Array(Set(self.users.compactMap {
            if let url = URL(string: $0.image) {
                url
            } else {
                nil
            }
        }))
        
        Prefetcher.prefetchImages(uniqueImages)
    }
}
