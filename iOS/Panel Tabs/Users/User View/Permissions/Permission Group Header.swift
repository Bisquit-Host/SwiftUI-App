import SwiftUI
import PteroNet

struct PermissionGroupHeader: View {
    @Environment(UsersVM.self) private var vm
    
    private let user: UserAttributes
    @Binding private var showDescription: Bool
    
    init(_ showDescription: Binding<Bool>, user: UserAttributes) {
        _showDescription = showDescription
        self.user = user
    }
    
    var permissionCount: Int {
        var count = 0
        
        if let permissions = vm.permissions {
            for (_, permission) in permissions.permissions {
                count += permission.keys.count
            }
        }
        
        return count
    }
    
    private var permissionCountColor: Color {
        switch user.permissions.count {
        case 0:               .red
        case permissionCount: .green
        default:              .yellow
        }
    }
    
    var body: some View {
        Section {
            HStack(spacing: 0) {
                Text("Permissions")
                
                Spacer()
                
                let userPerms = Text(user.permissions.count)
                    .monospaced()
                
                let totalPerms = Text(permissionCount)
                    .monospaced()
                
                Text("\(userPerms) / \(totalPerms)")
                    .foregroundStyle(permissionCountColor)
                    .animation(.easeInOut, value: user.permissions)
                    .numericTransition()
            }
            
            Toggle("Show description", isOn: $showDescription)
        }
    }
}

#Preview {
    @Previewable @State var showDescription = false
    
    List {
        PermissionGroupHeader($showDescription, user: sampleJSON(.userAttributes))
    }
}
