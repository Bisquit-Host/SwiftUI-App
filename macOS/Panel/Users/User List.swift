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
                ForEach(vm.users, id: \.uuid) { user in
                    UserCard(user)
                }
            }
        }
        .navigationTitle("Users")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            vm.fetchUsers()
            vm.fetchPermissions()
        }
        .onChange(of: id) { _, _ in
            vm.fetchUsers()
            vm.fetchPermissions()
        }
    }
}

#Preview {
    Text("Preview")
        .sheet(.constant(true)) {
            UserList("")
        }
        .environment(UsersVM(""))
}
