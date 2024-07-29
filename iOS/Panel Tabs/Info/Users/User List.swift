import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    @State private var sheetInvitation = false
    
    var body: some View {
        List {
            Section {
                ForEach(vm.users, id: \.uuid) { user in
                    UserCard(user)
                }
                .onDelete(perform: delete)
            }
            
            Button("New User") {
                sheetInvitation = true
            }
        }
        .environment(vm)
        .navigationTitle("Users")
        .toolbarTitleDisplayMode(.inline)
        .task {
            vm.fetchUsers()
            vm.fetchPermissions()
        }
        .refreshable {
            vm.fetchUsers()
        }
        .sheet($sheetInvitation) {
            UserInvitationView()
        }
    }
    
    private func delete(offsets: IndexSet) {
        offsets.forEach { index in
            let user = vm.users[index]
            vm.delete(user.uuid)
        }
    }
}

#Preview {
    Text("Preview")
        .sheet {
            UserList()
        }
        .environment(UsersVM("2fb25a50"))
}
