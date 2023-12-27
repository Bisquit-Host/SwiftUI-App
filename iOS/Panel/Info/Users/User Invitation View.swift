import SwiftUI
import Algorithms

struct UserInvitationView: View {
    @Environment(UsersVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var sheetContacts = false
    
    private var chunkedPermissions: [String: [String]] {
        var dict = [String: [String]]()
        
        for permission in vm.userPermissionsDict.keys.sorted() {
            let components = permission.split(separator: ".").map(String.init)
            
            if components.count > 1 {
                let type = components[0]
                dict[type, default: []].append(permission)
            }
        }
        
        return dict
    }
    
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
            }
            
            ForEach(chunkedPermissions.keys.sorted(), id: \.self) { type in
                Section(type) {
                    ForEach(chunkedPermissions[type] ?? [], id: \.self) { permission in
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
#if os(iOS)
        .sheet(isPresented: $sheetContacts) {
            ContactPickerView($email)
                .ignoresSafeArea()
        }
#endif
    }
}

#Preview {
    UserInvitationView()
        .environment(UsersVM(""))
}
