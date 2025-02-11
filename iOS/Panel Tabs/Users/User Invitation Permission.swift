import SwiftUI

struct UserInvitationPermission: View {
    @Environment(UsersVM.self) private var vm
    
    private let permission: String
    
    init(_ permission: String) {
        self.permission = permission
    }
    
    @State private var isGranted = false
    
    private var subkey: String {
        permission.split(separator: ".").last?.description ?? permission
    }
    
    var body: some View {
        Toggle(subkey, isOn: $isGranted)
            .onChange(of: vm.allPermsTrigger) { _, newValue in
                isGranted = newValue
            }
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
