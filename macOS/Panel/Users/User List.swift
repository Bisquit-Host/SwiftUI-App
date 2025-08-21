import SwiftUI

struct UserList: View {
    @State private var vm: UsersVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = UsersVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.users) { user in
                    UserCard(user)
                }
            }
        }
        .animation(.default, value: vm.users.indices)
        .environment(vm)
        .navigationTitle("Users")
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
        .onChange(of: id) {
            Task {
                await vm.fetchUsers()
                await vm.fetchPermissions()
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserList("")
    }
    .darkSchemePreferred()
}
