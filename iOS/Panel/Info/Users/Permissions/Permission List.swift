import SwiftUI
import PteroNet

struct PermissionList: View {
    @Environment(UsersVM.self) private var vm
    
    @Binding private var user: UserListAttributes
    
    init(_ user: Binding<UserListAttributes>) {
        _user = user
    }
    
    @State private var showDescription = false
    
    private var userPermissionsDict: [String: Bool] {
        var dict: [String: Bool] = [:]
        
        if let permissions = vm.permissions {
            permissions.permissions.forEach { key, permission in
                permission.keys.keys.forEach { subKey in
                    let fullKey = "\(key).\(subKey)"
                    
                    dict[fullKey] = user.permissions.contains(fullKey)
                }
            }
        }
        
        return dict
    }
    
    var body: some View {
        if let permissions = vm.permissions {
            
            PermissionsHeader(user,
                              showDescription: $showDescription)
            
            ForEach(permissions.permissions.keys.sorted(), id: \.self) { key in
                if let permission = permissions.permissions[key] {
                    Section {
                        ForEach(permission.keys.keys.sorted(), id: \.self) { subKey in
                            if let subValue = permission.keys[subKey] {
                                
                                let perm = userPermissionsDict["\(key).\(subKey)"]
                                
                                VStack(alignment: .leading) {
                                    PermissionCard(
                                        userPermissions: user.permissions,
                                        user: $user,
                                        key: key,
                                        subKey: subKey,
                                        perm: perm
                                    )
                                    
                                    if showDescription {
                                        Text(subValue)
                                            .caption2()
                                    }
                                }
                            }
                        }
                    } header: {
                        Text(key)
                    } footer: {
                        if showDescription {
                            Text(permission.description)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PermissionList(.constant(
        sampleJSON(.userAttributes)
    ))
}
