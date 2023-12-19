import SwiftUI
import PteroNet

struct PermissionCard: View {
    @Environment(UsersVM.self) private var vm
    
    @State private var userPermissions: [String]
    private let userId: String
    private let key: Dictionary<String, Permission>.Keys.Element
    private let subKey: Dictionary<String, String>.Keys.Element
    private let perm: Bool?
    
    init(userPermissions: [String],
         userId: String,
         key: Dictionary<String, Permission>.Keys.Element,
         subKey: Dictionary<String, String>.Keys.Element,
         perm: Bool?
    ) {
        self.userPermissions = userPermissions
        self.userId = userId
        self.key = key
        self.subKey = subKey
        self.perm = perm
        isGranted = perm ?? false
    }
    
    @State private var isGranted: Bool
    
    var body: some View {
        Toggle(isOn: $isGranted) {
            Text(subKey)
        }
        .onChange(of: isGranted) { _, newValue in
            if newValue {
                userPermissions.append("\(key).\(subKey)")
            } else {
                if vm.permissions?.permissions[key] != nil {
                    //                    vm.permissions?.permissions.removeValue(forKey: key)
                    userPermissions.removeAll(where: {
                        $0 == "\(key).\(subKey)"
                    })
                }
            }
            
            vm.updateUser(userId, permissions: userPermissions)
//            vm. FETCH USER DETAILS
        }
    }
}

//#Preview {
//    PermissionCard()
//}
