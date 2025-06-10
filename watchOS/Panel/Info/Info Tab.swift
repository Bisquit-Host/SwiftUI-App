import SwiftUI
import PteroNet

struct InfoTab: View {
    private let server: ServerAttributes
    private var users: UsersVM
    private var logs: LogVM
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.users = UsersVM(server.id)
        self.logs = LogVM(server.id)
    }
    
    var body: some View {
        ScrollView {
            NavigationLink {
                UserListParent()
                    .environment(users)
            } label: {
                Label("Users", systemImage: "person.3")
            }
            
            NavigationLink {
                LogListParent()
                    .environment(logs)
            } label: {
                Label("Logs", systemImage: "list.bullet.rectangle")
            }
        }
        .navigationTitle("Info")
        .task {
            async let users: () = users.fetchUsers()
            async let logs: () = logs.fetchLogs()
            
            _ = await (users, logs)
        }
    }
}

#Preview {
    InfoTab(sampleJSON(.serverListAttributes))
}
