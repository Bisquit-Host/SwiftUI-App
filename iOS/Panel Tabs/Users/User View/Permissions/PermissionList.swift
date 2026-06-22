import SwiftUI
import Calagopus

struct PermissionList: View {
    @Environment(SubuserVM.self) private var vm
    
    @Binding private var user: CalagopusServerSubuser
    
    init(_ user: Binding<CalagopusServerSubuser>) {
        _user = user
    }
    
    @State private var showDescription = false
    
    var body: some View {
        if let permissions = vm.permissions {
            PermissionGroupHeader($showDescription, user: user)
            
            ForEach(permissions.permissions.keys.sorted(), id: \.self) { key in
                PermissionSection(
                    key: key,
                    permission: permissions.permissions[key],
                    showDescription: $showDescription,
                    user: $user
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var user: CalagopusServerSubuser = PreviewProp.userAttributes
    
    PermissionList($user)
        .darkSchemePreferred()
        .environment(SubuserVM(""))
}
