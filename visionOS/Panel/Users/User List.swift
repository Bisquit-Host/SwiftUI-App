import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.users) { user in
                UserCard(user)
            }
        }
        .refreshableTask {
            vm.fetchUsers()
        }
    }
}

#Preview {
    UserList()
        .environment(UsersVM(""))
}
