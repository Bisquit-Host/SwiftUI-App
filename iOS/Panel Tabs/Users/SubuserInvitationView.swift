import ScrechKit

struct SubuserInvitationView: View {
    @Environment(SubuserVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var sheetContacts = false
    
    var body: some View {
        List {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
#if os(iOS)
                Button("Contacts", systemImage: "person.circle.fill") {
                    sheetContacts = true
                }
#endif
                Button {
                    vm.allPermsTrigger.toggle()
                } label: {
                    Text(vm.allPermsTrigger ? String(localized: "Revoke all permissions") : String(localized: "Grant all permissions"))
                        .animation(.default, value: vm.allPermsTrigger)
                }
            }
            
            ForEach(vm.chunkedPermissions.keys.sorted(), id: \.self) { type in
                Section(type) {
                    ForEach(vm.chunkedPermissions[type] ?? [], id: \.self) {
                        SubuserInvitationPermission($0)
                    }
                }
            }
            
            Section {
                AsyncButton("Invite") {
                    await vm.createUser(email) {
                        dismiss()
                    }
                }
                .disabled(vm.newUserPermissions.isEmpty)
            }
        }
        .navigationTitle("Invite Subuser")
        .toolbarTitleDisplayMode(.inline)
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .task {
            await vm.fetchPermissions()
        }
#if os(iOS)
        .sheet($sheetContacts) {
            NavigationStack {
                ContactsListView($email)
            }
        }
#endif
    }
}

#Preview {
    SubuserInvitationView()
        .darkSchemePreferred()
        .environment(SubuserVM(""))
}
