import SwiftUI

struct UserInvitationView: View {
    @Environment(UsersVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    
    var body: some View {
        List {
            Section {
                TextField("E-mail", text: $email)
                    .textContentType(.emailAddress)
            }
            
            ForEach(vm.userPermissionsDict.keys.sorted(), id: \.self) { permission in
                UserInvitationPermission(permission)
            }
            
            Section {
                Button {
                    vm.createUser(email) {
                        dismiss()
                    }
                } label: {
                    Text("Invite User")
                }
                .disabled(vm.newUserPermissions.isEmpty)
            }
        }
        .padding(.horizontal)
        .scrollIndicators(.never)
        .presentationDetents([.medium])
        .task {
            vm.fetchPermissions()
        }
//        .onChange(of: userPermissionsDict) { _, newValue in
//            
//        }
    }
}

#Preview {
    UserInvitationView()
        .environment(UsersVM(""))
}
