import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            ForEach(vm.users) { user in
                UserCard(user)
            }
#if os(iOS)
            .listSectionSpacing(-10)
#endif
        }
        .navigationTitle("Users")
        .environment(vm)
#if !os(tvOS)
        .toolbarTitleDisplayMode(.large)
#endif
        .task {
            // Both funcs will run parallel
            // Shouldn't change same props,
            // Otherwise will cause a data race
            
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
            ToolbarItem(placement: .topBarLeading) {
                DismissButton {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    vm.sheetInvitation = true
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
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
        .environment(UsersVM("2fb25a50"))
}
