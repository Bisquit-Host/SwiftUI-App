import SwiftUI

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
                Button("Contacts", systemImage: "person.circle.fill") {
                    sheetContacts = true
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
                    ForEach(vm.chunkedPermissions[type] ?? [], id: \.self) {
                        UserInvitationPermission($0)
                    }
                }
            }
            
            Section {
                Button("Invite user") {
                    Task {
                        await vm.createUser(email) {
                            dismiss()
                        }
                    }
                }
                .disabled(vm.newUserPermissions.isEmpty)
            }
        }
        .padding(.horizontal)
        .scrollIndicators(.never)
        .task {
            await vm.fetchPermissions()
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
        .darkSchemePreferred()
        .environment(UsersVM(""))
}
