import ScrechKit

struct UserList: View {
    @Environment(UsersVM.self) private var vm

    var body: some View {
        @Bindable var vm = vm
        
        List {
            ForEach(vm.users) {
                UserCard($0)
            }
            .onDelete(perform: delete)
#if os(iOS)
            .listSectionSpacing(-10)
#endif
        }
        .navigationTitle("Users")
        .environment(vm)
        .task {
            await vm.fetchUsers()
            await vm.fetchPermissions()
        }
        .refreshableTask {
            let usersTask = Task {
                await vm.fetchUsers()
            }
            
            let permissionsTask = Task {
                await vm.fetchPermissions()
            }
            
            await usersTask.value
            await permissionsTask.value
        }
        .sheet($vm.sheetInvitation) {
            UserInvitationView()
        }
#if os(iOS) || os(macOS) || os(visionOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .overlay {
            if vm.users.isEmpty {
                ContentUnavailableView(
                    "This server currently has no users",
                    systemImage: "person.3.fill",
                    description: Text("Click the button in the top right corner to send an invitation")
                )
            }
        }
        .toolbar {
#if !os(watchOS) && !os(tvOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
            ToolbarItem(placement: .bottomBar) {
                SFButton("person.crop.circle.badge.plus") {
                    vm.sheetInvitation = true
                }
            }
        }
    }
    
    private func delete(_ offsets: IndexSet) {
        offsets.forEach { index in
            let user = vm.users[index]
            
            Task {
                await vm.delete(user.uuid)
            }
        }
    }
}

#Preview {
    Text("Preview")
        .sheet {
            UserList()
        }
        .darkSchemePreferred()
        .environment(UsersVM(""))
}
