import SwiftUI
import PteroNet

struct InfoTab: View {
    //    private var settingsVM: ServerSettingsVM
    private let server: ServerListAttributes
    private var logVM: LogVM
    private var usersVM: UsersVM
    private var allocationVM: AllocationVM
    //    @EnvironmentObject private var settings: SettingsStorage
    @Environment(NavState.self) private var navState
    
    init(_ server: ServerListAttributes,
         //         modelRename: ServerSettingsVM = ServerSettingsVM(""),
         logVM: LogVM = LogVM(""),
         modelUsers: UsersVM = UsersVM(""),
         allocationVM: AllocationVM = AllocationVM("")
    ) {
        self.server = server
        //        self.settingsVM = ServerSettingsVM(server.id)
        self.logVM = LogVM(server.id)
        self.usersVM = UsersVM(server.id)
        self.allocationVM = AllocationVM(server.id)
    }
    
    var body: some View {
        VStack(spacing: 60) {
            HStack {
                NavigationLink {
                    UserList()
                        .environment(usersVM)
                } label: {
                    Label("Users", systemImage: "person.3")
                        .frame(width: 500, height: 250)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 64))
                }
                
                NavigationLink {
                    LogList()
                        .environment(logVM)
                } label: {
                    Label("Logs", systemImage: "terminal")
                        .frame(width: 500, height: 250)
                        .background(.ultraThinMaterial,
                                    in: .rect(cornerRadius: 64))
                }
            }
            
            HStack {
                NavigationLink {
                    
                } label: {
                    Label("Allocations", systemImage: "network")
                        .frame(width: 500, height: 250)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 64))
                }
                .disabled(true)
                
                NavigationLink {
                    
                } label: {
                    Label("Startup", systemImage: "airplane")
                        .frame(width: 500, height: 250)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 64))
                }
                .disabled(true)
            }
        }
        .title2()
        .buttonStyle(.plain)
        .task {
            usersVM.fetchUsers()
            logVM.fetchLogs()
            allocationVM.fetchAllocations()
        }
    }
}

#Preview {
    NavigationView {
        InfoTab(
            sampleJSON(.serverListAttributes)
        )
    }
    .environment(LogVM(""))
    .environment(NavState())
}
