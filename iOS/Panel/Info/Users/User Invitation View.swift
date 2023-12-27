import SwiftUI
import Algorithms

struct UserInvitationView: View {
    @Environment(UsersVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var sheetContacts = false
        
    var body: some View {
        List {
            Section {
                TextField("E-mail", text: $email)
                    .textContentType(.emailAddress)
#if os(iOS)
                Button {
                    sheetContacts = true
                } label: {
                    Label("Contacts", systemImage: "person.circle.fill")
                }
#endif
                Button {
                    vm.allPermsTrigger.toggle()
                } label: {
                    Text(vm.allPermsTrigger ? "Revoke all permissions" : "Grant all permissions")
                        .animation(.default, value: vm.allPermsTrigger)
                }
            }
            
            ForEach(vm.chunkedPermissions.keys.sorted(), id: \.self) { type in
                Section(type) {
                    ForEach(vm.chunkedPermissions[type] ?? [], id: \.self) { permission in
                        UserInvitationPermission(permission)
                    }
                }
            }
            
            Section {
                Button {
                    vm.createUser(email) {
                        dismiss()
                    }
                } label: {
                    Text("Invite user")
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
#if os(iOS)
        .sheet(isPresented: $sheetContacts) {
            ContactsListView($email)
        }
#endif
    }
}

#Preview {
    UserInvitationView()
        .environment(UsersVM(""))
}
