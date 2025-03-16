import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            ForEach(vm.users) { user in
                Section {
                    UserCard(user)
                }
                .transparentSection()
            }
            .onDelete(perform: delete)
#if os(iOS)
            .listSectionSpacing(-10)
#endif
            Section {
                Button {
                    vm.sheetInvitation = true
                } label: {
                    Label("New user", systemImage: "person.badge.plus")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.foreground)
                        .padding()
                        .background(.ultraThinMaterial.opacity(0.3), in: .rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray.opacity(0.25), lineWidth: 1)
                        }
                }
            }
            .transparentSection()
            .padding(.top)
        }
        .environment(vm)
        .navigationTitle("Users")
        .toolbarTitleDisplayMode(.inline)
        .transparentList()
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
