import SwiftUI
import PteroNet

struct InfoTab: View {
    private let server: ServerAttributes
    private var users: UsersVM
    private var logs: LogVM
    
    init(_ server: ServerAttributes,
         users: UsersVM = UsersVM(""),
         logs: LogVM = LogVM("")
    ) {
        self.server = server
        self.users = UsersVM(server.id)
        self.logs = LogVM(server.id)
    }
    
    var body: some View {
        ScrollView {
            NavigationLink("Users") {
                UserListParent()
                    .environment(users)
            }
            
            NavigationLink("Logs") {
                LogListParent()
                    .environment(logs)
            }
        }
        .navigationTitle("Info")
        .task {
            users.fetchUsers()
            logs.fetchLogs()
        }
    }
}

#Preview {
    InfoTab(
        sampleJSON(.serverListAttributes)
    )
}
