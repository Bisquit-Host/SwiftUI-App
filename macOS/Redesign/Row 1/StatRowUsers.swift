import SwiftUI

struct StatRowUsers: View {
    @State private var vm: UsersVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = UsersVM(id)
    }
    
    @State private var sheetUserList = false
    
    var body: some View {
        Button {
            sheetUserList = true
        } label: {
            StatTile("Users", value: vm.users.count, icon: "person.2")
        }
        .sheet($sheetUserList) {
            UserList(id)
                .environment(vm)
        }
        .task {
            await vm.fetchUsers()
            await vm.fetchPermissions()
        }
    }
}

#Preview {
    StatRowUsers("")
        .darkSchemePreferred()
}
