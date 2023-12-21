import SwiftUI
import PteroNet

struct PermissionCard: View {
    @Environment(UsersVM.self) private var vm
    
    @State private var userPermissions: [String]
    @Binding private var user: UserAttributes
    private let key: String
    private let subKey: String
    private let perm: Bool?
    
    init(userPermissions: [String],
         user: Binding<UserAttributes>,
         key: String,
         subKey: String,
         perm: Bool?
    ) {
        self.userPermissions = userPermissions
        _user = user
        self.key = key
        self.subKey = subKey
        self.perm = perm
        isGranted = perm ?? false
    }
    
    @State private var isGranted: Bool
    @State private var allowUpdate = true
    
    var body: some View {
        Toggle(isOn: $isGranted) {
            Text(subKey)
        }
#if os(tvOS)
        .foregroundStyle(isGranted ? .green : .red)
#endif
        .onChange(of: perm) { _, newValue in
            if let perm {
                isGranted = perm
            }
        }
        .onChange(of: isGranted) { _, newValue in
            if allowUpdate {
                if newValue {
                    userPermissions.append("\(key).\(subKey)")
                } else {
                    if vm.permissions?.permissions[key] != nil {
                        userPermissions.removeAll(where: {
                            $0 == "\(key).\(subKey)"
                        })
                    }
                }
                
                vm.updateUser(user.uuid, permissions: userPermissions) {
                    vm.userDetails($user)
                } onError: {
                    allowUpdate = false
                    isGranted.toggle()
                }
            }
            
            allowUpdate = true
        }
    }
}

//#Preview {
//    PermissionCard()
//}
