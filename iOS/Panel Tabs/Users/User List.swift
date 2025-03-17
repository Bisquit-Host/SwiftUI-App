import SwiftUI

struct UserList: View {
    @Environment(UsersVM.self) private var vm
    
    var body: some View {
        @Bindable var vm = vm
        
        List {
            HStack {
                Text("Users")
                    .largeTitle(.bold, design: .rounded)
                
                Spacer()
                
                Button {
                    vm.sheetInvitation = true
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .title3()
                        .foregroundStyle(.foreground)
                        .footnote(.bold)
                        .frame(width: 35, height: 35)
                        .background(.ultraThinMaterial, in: .circle)
                }
            }
            .listRowBackground(Color.clear)
            
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
        .environment(vm)
        .padding(.top, -16)
//        .navigationTitle("Users")
//#if os(iOS)
//        .toolbarTitleDisplayMode(.inlineLarge)
//#endif
        .transparentList()
        .task {
            vm.fetchUsers()
            vm.fetchPermissions()
        }
        .sheet($vm.sheetInvitation) {
            UserInvitationView()
        }
//        .toolbar {
//            Button {
//                vm.sheetInvitation = true
//            } label: {
//                Image(systemName: "person.crop.circle.badge.plus")
//                    .foregroundStyle(.foreground)
//                    .footnote(.bold)
//                    .frame(width: 35, height: 35)
//                    .background(.ultraThinMaterial, in: .circle)
//            }
//        }
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
