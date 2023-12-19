import SwiftUI
import PteroNet

struct PermissionList: View {
    @Environment(UsersVM.self) private var vm
    
    private let user: UserListAttributes
    
    init(_ user: UserListAttributes) {
        self.user = user
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
    
    private var permissionCount: Int {
        var count = 0
        
        if let permissions = vm.permissions {
            for (_, permission) in permissions.permissions {
                count += permission.keys.count
            }
        }
        
        return count
    }
    
    private var permissionCountColor: Color {
        let userPermissions = user.permissions.count
        
        if userPermissions == 0 {
            return .red
            
        } else if userPermissions < permissionCount {
            return .yellow
        }
        
        return .green
    }
    
    var body: some View {
        if let permissions = vm.permissions {
            Section {
                HStack {
                    Text("Permissions")
                    
                    Spacer()
                    
                    Text("\(user.permissions.count) of \(permissionCount)")
                        .foregroundStyle(permissionCountColor)
                }
                
                Toggle("Show description (ru)", isOn: $showDescription)
            }
            
            ForEach(permissions.permissions.keys.sorted(), id: \.self) { key in
                if let permission = permissions.permissions[key] {
                    Section {
                        ForEach(permission.keys.keys.sorted(), id: \.self) { subKey in
                            if let subValue = permission.keys[subKey] {
                                
                                let perm = userPermissionsDict["\(key).\(subKey)"]
                                
                                VStack(alignment: .leading) {
                                    PermissionCard(
                                        userPermissions: user.permissions,
                                        userId: user.uuid,
                                        key: key,
                                        subKey: subKey,
                                        perm: perm
                                    )
                                    
//                                    Toggle(isOn: .constant(perm ?? false)) {
//                                        Text(subKey)
//                                    }
//                                    .disabled(true)
                                    
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
    PermissionList(
        sampleJSON(.userAttributes)
    )
}
