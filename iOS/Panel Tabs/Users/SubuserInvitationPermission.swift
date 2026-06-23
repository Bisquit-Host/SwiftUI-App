import SwiftUI

struct SubuserInvitationPermission: View {
    @Environment(SubuserVM.self) private var vm
    
    private let permission: String
    
    init(_ permission: String) {
        self.permission = permission
    }
    
    @State private var isGranted = false
    
    var body: some View {
        let subkey = permission.split(separator: ".").last?.description ?? permission
        
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
    List {
        SubuserInvitationPermission("Preview")
    }
    .darkSchemePreferred()
    .environment(SubuserVM(""))
}
