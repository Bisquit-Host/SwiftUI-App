import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.users) {
                UserCard($0)
            }
        }
        .refreshableTask {
            await vm.fetchUsers()
        }
    }
}

#Preview {
    UserList()
        .environment(UsersVM(""))
}
