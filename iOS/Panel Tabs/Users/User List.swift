import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
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
        }
        .padding(.horizontal)
        .environment(vm)
        .navigationTitle("Users")
#if !os(tvOS)
        .toolbarTitleDisplayMode(.large)
#endif
        .transparentList()
        .task {
            vm.fetchUsers()
            vm.fetchPermissions()
        }
        .sheet($vm.sheetInvitation) {
            UserInvitationView()
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
                        .foregroundStyle(.foreground)
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
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
