import ScrechKit
import Calagopus

struct PermissionSection: View {
    @Environment(SubuserVM.self) private var vm
    
    var key: String
    var permission: Permission?
    @Binding var showDescription: Bool
    @Binding var user: UserAttributes
    
    @State private var showTranslation = false
    
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
                Text(key.capitalized)
            } footer: {
                if showDescription {
                    Text(permission.description)
                        .secondary()
                        .multilineTextAlignment(.leading)
#if os(iOS) || os(macOS)
                        .translationPresentation($showTranslation, text: permission.description)
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
