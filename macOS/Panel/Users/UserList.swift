import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.users) {
                    UserCard($0)
                }
            }
        }
        .navigationTitle("Users")
        .animation(.default, value: vm.users.indices)
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            let usersTask = Task {
                await vm.fetchUsers()
            }
            
            let permissionsTask = Task {
                await vm.fetchPermissions()
            }
            
            await usersTask.value
            await permissionsTask.value
        }
    }
}

#Preview {
    NavigationStack {
        UserList("")
    }
    .darkSchemePreferred()
    .environment(UsersVM(""))
}
