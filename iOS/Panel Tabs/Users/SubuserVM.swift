import SwiftUI
import Calagopus

@Observable
final class SubuserVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var users: [CalagopusServerSubuser] = []
    private(set) var permissions: CalagopusServerPermissions?
    
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
            let user = try await CalagopusNet.client().createSubuser(server: id, email: email, permissions: newUserPermissions)
            users.append(user)
            
            onSuccess()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func updateUser(_ userId: String, permissions: [String]) async throws {
        _ = try await CalagopusNet.client().updateSubuser(server: id, subuser: userId, permissions: permissions)
    }
    
    func userDetails(_ user: Binding<CalagopusServerSubuser>) async {
        do {
            let userDetails = try await CalagopusNet.client().subusers(server: id).data.first {
                $0.user.uuid == user.wrappedValue.user.uuid
            }
            
            guard let userDetails else {
                return
            }
            
            user.wrappedValue = userDetails
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchPermissions() async {
        do {
            permissions = try await CalagopusNet.client().permissions()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchUsers(_ prefetch: Bool = false) async {
        do {
            self.users = try await CalagopusNet.client().subusers(server: id).data
            
            if !prefetch {
                self.prefetchUserImages()
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func delete(_ uuid: String) async {
        do {
            try await CalagopusNet.client().deleteSubuser(server: id, subuser: uuid)
        } catch {
            SystemAlert.error(error)
        }
        
        await fetchUsers()
    }
    
    private func prefetchUserImages() {
        let uniqueImages = Array(Set(self.users.compactMap {
            if let image = $0.user.avatar, let url = URL(string: image) {
                url
            } else {
                nil
            }
        }))
        
        Prefetcher.prefetchImages(uniqueImages)
    }
}
