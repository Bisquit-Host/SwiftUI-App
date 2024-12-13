import SwiftUI
import PteroNet
import Translation

struct PermissionListView: View {
    @Environment(UsersVM.self) private var vm
    
    @Binding private var user: UserAttributes
    
    init(_ user: Binding<UserAttributes>) {
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
            PermissionsHeader($showDescription, user: user)
            
            PermissionsList(
                permissions: permissions.permissions,
                showDescription: $showDescription,
                user: $user,
                userPermissionsDict: userPermissionsDict
            )
        }
    }
}

struct PermissionsList: View {
    var permissions: [String: Permission]
    @Binding var showDescription: Bool
    @Binding var user: UserAttributes
    var userPermissionsDict: [String: Bool]
    
    var body: some View {
        ForEach(permissions.keys.sorted(), id: \.self) { key in
            PermissionSection(
                key: key,
                permission: permissions[key],
                showDescription: $showDescription,
                user: $user,
                userPermissionsDict: userPermissionsDict
            )
        }
    }
}

struct PermissionSection: View {
    var key: String
    var permission: Permission?
    @Binding var showDescription: Bool
    @Binding var user: UserAttributes
    var userPermissionsDict: [String: Bool]
    
    @State private var showTranslation = false
    
    var body: some View {
        if let permission {
            Section {
                ForEach(permission.keys.keys.sorted(), id: \.self) { subKey in
                    PermissionCard(
                        key: key,
                        subKey: subKey,
                        subValue: permission.keys[subKey],
                        showDescription: $showDescription,
                        user: $user,
                        userPermissionsDict: userPermissionsDict
                    )
                }
            } header: {
                Text(key)
            } footer: {
                if showDescription {
                    Text(permission.description)
#if os(iOS) || os(macOS)
                        .translationPresentation(isPresented: $showTranslation, text: permission.description)
                        .onTapGesture {
                            showTranslation = true
                        }
#endif
                }
            }
#if os(tvOS)
            Divider()
#endif
        }
    }
}

struct PermissionCard: View {
    var key: String
    var subKey: String
    var subValue: String?
    @Binding var showDescription: Bool
    @Binding var user: UserAttributes
    var userPermissionsDict: [String: Bool]
    
    @State private var showTranslation = false
    
    var body: some View {
        if let subValue {
            let perm = userPermissionsDict["\(key).\(subKey)"]
            
            VStack(alignment: .leading) {
                PermissionToggle(
                    userPermissions: user.permissions,
                    user: $user,
                    key: key,
                    subKey: subKey,
                    perm: perm
                )
                
                if showDescription {
                    Text(subValue)
                        .caption2()
#if os(iOS) || os(macOS)
                        .translationPresentation(isPresented: $showTranslation, text: subValue)
                        .onTapGesture {
                            showTranslation = true
                        }
#endif
                }
            }
        }
    }
}

#Preview {
    PermissionListView(.constant(sampleJSON(.userAttributes)))
        .environment(UsersVM(""))
}
