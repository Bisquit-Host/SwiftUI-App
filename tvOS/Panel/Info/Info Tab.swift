import SwiftUI
import PteroNet

struct InfoTab: View {
    //    private var settingsVM: ServerSettingsVM
    private var logVM: LogVM
    private var usersVM: UsersVM
    private let server: ServerListAttributes
    //    @EnvironmentObject private var settings: SettingsStorage
    @Environment(NavState.self) private var navState
    
    init(_ server: ServerListAttributes,
         //         modelRename: ServerSettingsVM = ServerSettingsVM(""),
         logVM: LogVM = LogVM(""),
         modelUsers: UsersVM = UsersVM("")
    ) {
        self.server = server
        //        self.settingsVM = ServerSettingsVM(server.id)
        self.logVM = LogVM(server.id)
        self.usersVM = UsersVM(server.id)
    }
    
    var body: some View {
        VStack(spacing: 60) {
            HStack {
                NavigationLink {
                    
                    //                    .environment(usersVM)
                } label: {
                    Label("Users", systemImage: "person.3")
                        .frame(width: 500, height: 250)
                        .background(.ultraThinMaterial,
                                    in: .rect(cornerRadius: 64))
                }
                .disabled(true)
                
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
                        .background(.ultraThinMaterial,
                                    in: .rect(cornerRadius: 64))
                }
                .disabled(true)
                
                NavigationLink {
                    
                } label: {
                    Label("Startup", systemImage: "airplane")
                        .frame(width: 500, height: 250)
                        .background(.ultraThinMaterial,
                                    in: .rect(cornerRadius: 64))
                }
                .disabled(true)
            }
        }
        .title2()
        .buttonStyle(.plain)
        .task {
            usersVM.fetchUsers()
            logVM.fetchLogs()
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
