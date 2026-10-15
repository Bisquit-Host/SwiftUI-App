import ScrechKit

struct DatabaseInstanceUsersSection: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    @State private var showCreateUser = false
    
    var body: some View {
        Section("Users") {
            ForEach(vm.users) {
                DatabaseInstanceUserRow($0)
            }
            
            Button("Create user", systemImage: "person.badge.plus") {
                showCreateUser = true
            }
            .disabled(vm.instance.isLocked)
        }
        .sheet($showCreateUser) {
            NavigationStack {
                DatabaseInstanceUserCreateSheet()
            }
            .environment(vm)
        }
    }
}

#Preview {
    List {
        DatabaseInstanceUsersSection()
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceDetailsVM("", instance: PreviewProp.databaseInstance))
}
