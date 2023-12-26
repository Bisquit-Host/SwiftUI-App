import SwiftUI
import PteroNet

struct InfoTab: View {
    //    private var settingsVM: ServerSettingsVM
    private let server: ServerAttributes
    private var logVM: LogVM
    private var usersVM: UsersVM
    private var allocationVM: AllocationVM
    private var startupVM: StartupVM
    //    @EnvironmentObject private var settings: SettingsStorage
    @Environment(NavState.self) private var navState
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.logVM = LogVM(server.id)
        self.usersVM = UsersVM(server.id)
        self.allocationVM = AllocationVM(server.id)
        self.startupVM = StartupVM(server.id)
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
                    AllocationList()
                        .environment(allocationVM)
                } label: {
                    Label("Allocations", systemImage: "network")
                        .frame(width: 500, height: 250)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 64))
                }
                
                NavigationLink {
                    StartupList()
                        .environment(startupVM)
                } label: {
                    Label("Startup", systemImage: "airplane")
                        .frame(width: 500, height: 250)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 64))
                }
            }
        }
        .title2()
        .buttonStyle(.plain)
        .task {
            usersVM.fetchUsers()
            logVM.fetchLogs()
            allocationVM.fetchAllocations()
            startupVM.fetchStartupVariables()
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
