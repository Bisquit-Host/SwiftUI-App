import ScrechKit
import PteroNet

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
                        .secondary()
                        .multilineTextAlignment(.leading)
#if os(iOS) || os(macOS)
                        .translationPresentation($showTranslation, text: subValue)
                        .onTapGesture {
                            showTranslation = true
                        }
#endif
                }
            }
        }
    }
}
