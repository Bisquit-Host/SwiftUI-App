import SwiftUI

struct UserInvitationPermission: View {
    @Environment(UsersVM.self) private var vm
    
    private let permission: String
    
    init(_ permission: String) {
        self.permission = permission
    }
    
    @State private var isGranted = false
    
    var body: some View {
        Toggle(permission, isOn: $isGranted)
            .onChange(of: isGranted) { _, newValue in
                guard newValue else {
                    vm.newUserPermissions.removeAll(where: { $0 == permission })
                    return
                }
                
                if !vm.newUserPermissions.contains(permission) {
                    vm.newUserPermissions.append(permission)
                }
            }
    }
}

#Preview {
    UserInvitationPermission("Preview")
}
