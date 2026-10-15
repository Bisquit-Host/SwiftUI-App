import ScrechKit
import Calagopus

struct DatabaseInstanceUserRow: View {
    @Environment(DatabaseInstanceDetailsVM.self) private var vm
    
    private let user: CalagopusDatabaseInstanceUser
    
    init(_ user: CalagopusDatabaseInstanceUser) {
        self.user = user
    }
    
    @State private var alertDelete = false
    
    var body: some View {
        NavigationLink {
            DatabaseInstanceCredentialsView(user.id)
                .environment(vm)
        } label: {
            VStack(alignment: .leading) {
                Text(user.username)
                    .headline()
                
                Text(vm.databaseName(user.databaseUuid) ?? String(localized: "All databases"))
                    .footnote()
                    .secondary()
            }
        }
        .swipeActions {
            if !vm.instance.isLocked {
                Button("Delete", systemImage: "trash") {
                    alertDelete = true
                }
                .labelStyle(.iconOnly)
                .tint(.red)
            }
        }
        .contextMenu {
            Button("Copy username", systemImage: "person") {
                Pasteboard.copy(user.username)
                SystemAlert.copied()
            }
            
            Button("Copy password", systemImage: "key") {
                Pasteboard.copy(user.password)
                SystemAlert.copied()
            }
            
            if !vm.instance.isLocked {
                AsyncButton("Rotate password", systemImage: "lock.open.rotation") {
                    await vm.rotatePassword(user.id)
                }
                
                Divider()
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    alertDelete = true
                }
            }
        }
        .alert("Delete User", isPresented: $alertDelete) {
            AsyncButton("Delete", role: .destructive) {
                await vm.deleteUser(user.id)
            }
        } message: {
            Text("Are you sure you want to delete \"\(user.username)\"? You can't undo this action")
        }
    }
}
