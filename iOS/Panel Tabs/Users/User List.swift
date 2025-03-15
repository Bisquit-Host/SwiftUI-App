import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            Section {
                ForEach(vm.users, id: \.uuid) { user in
                    UserCard(user)
                }
                .onDelete(perform: delete)
            }
            .listRowBackground(store.transparentList ? .clear : Color.list)
            
            Button {
                vm.sheetInvitation = true
            } label: {
                Label("New user", systemImage: "person.badge.plus")
            }
            .listRowBackground(store.transparentList ? .clear : Color.list)
        }
        .environment(vm)
        .navigationTitle("Users")
        .toolbarTitleDisplayMode(.inline)
        .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
        .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
        .task {
            vm.fetchUsers()
            vm.fetchPermissions()
        }
        .refreshable {
            vm.fetchUsers()
        }
        .sheet($vm.sheetInvitation) {
            UserInvitationView()
        }
    }
    
    private func delete(_ offsets: IndexSet) {
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
