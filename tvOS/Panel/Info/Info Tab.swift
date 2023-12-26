import SwiftUI
import PteroNet

struct InfoTab: View {
    private let id: String
    private var logVM: LogVM
    private var usersVM: UsersVM
    private var allocationVM: AllocationVM
    private var startupVM: StartupVM
    @Environment(NavState.self) private var navState
    
    init(_ id: String) {
        self.id = id
        self.logVM = LogVM(id)
        self.usersVM = UsersVM(id)
        self.allocationVM = AllocationVM(id)
        self.startupVM = StartupVM(id)
    }
    
    var body: some View {
        VStack(spacing: 60) {
            HStack {
                NavigationLink {
                    UserListParent()
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
        InfoTab("")
    }
    .environment(LogVM(""))
    .environment(UsersVM(""))
    .environment(AllocationVM(""))
    .environment(StartupVM(""))
    .environment(NavState())
}
