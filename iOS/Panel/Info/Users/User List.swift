import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    var body: some View {
#if !os(watchOS)
        NavigationView {
            List {
                Section {
                    ForEach(vm.users, id: \.attributes.uuid) { user in
                        UserCard(user.attributes)
                            .environment(vm)
                    }
                    .onDelete(perform: delete)
                }
                
                //                Button("New User") {
                //
                //                }
            }
            .navigationTitle("Users")
            .toolbarTitleDisplayMode(.inline)
            .refreshable {
                vm.fetchUsers()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .task {
            vm.fetchUsers()
            vm.fetchPermissions()
        }
#else
        List {
            Section {
                ForEach(vm.users, id: \.attributes.uuid) { user in
                    UserCard(user.attributes)
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Users")
        .task {
            vm.fetchUsers()
            vm.fetchPermissions()
        }
#endif
    }
    
    private func delete(offsets: IndexSet) {
        offsets.forEach { index in
            let user = vm.users[index]
            vm.delete(user.attributes.uuid)
        }
    }
}

#Preview {
    Text("Preview")
        .sheet(.constant(true)) {
            UserList()
        }
        .environment(UsersVM("2fb25a50"))
}
