import SwiftUI

struct StatRowUsers: View {
    @State private var vm: SubuserVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = SubuserVM(id)
    }
    
    @State private var sheetUserList = false
    
    var body: some View {
        Button {
            sheetUserList = true
        } label: {
            StatTile("Users", value: vm.users.count, icon: "person.2")
        }
        .task {
            await vm.fetchUsers()
            await vm.fetchPermissions()
        }
        .sheet($sheetUserList) {
            SubuserList(id)
                .environment(vm)
                .frame(minHeight: StatRows.minHeight)
        }
    }
}

#Preview {
    StatRowUsers("")
        .darkSchemePreferred()
}
