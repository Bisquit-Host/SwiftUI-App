import ScrechKit
import PteroNet

struct InfoTabButtons: View {
    private let server: ServerAttributes
    private var settingsVM: ServerSettingsVM
    private var logVM: LogVM
    private var userVM: UsersVM
    private var subdomainVM: SubdomainVM
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.settingsVM = ServerSettingsVM(server.id)
        self.logVM = LogVM(server.id)
        self.userVM = UsersVM(server.id)
        self.subdomainVM = SubdomainVM(server.id)
    }
    
    @State private var sheetUsers = false
    @State private var sheetLogs = false
    @State private var sheetSubdomains = false
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    sheetLogs = true
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .foregroundStyle(.tertiary)
                        
                        Text("Logs")
                            .semibold()
                    }
                    .footnote()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.foreground)
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay {
                        Capsule()
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
                }
                
                Button {
                    sheetSubdomains = true
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "globe")
                            .foregroundStyle(.tertiary)
                        
                        Text("Subdomains")
                            .semibold()
                    }
                    .footnote()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.foreground)
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay {
                        Capsule()
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
                }
            }
            
            Menu {
                Button {
                    sheetUsers = true
                    userVM.sheetInvitation = true
                } label: {
                    Label("New user", systemImage: "person.badge.plus")
                }
            } label: {
                Button {
                    sheetUsers = true
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(.tertiary)
                        
                        Text("Users")
                            .semibold()
                    }
                    .footnote()
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.foreground)
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay {
                        Capsule()
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    }
                }
            } primaryAction: {
                sheetUsers = true
            }
        }
        .sheet($sheetUsers) {
            UserListParent()
                .environment(userVM)
        }
        .sheet($sheetLogs) {
            LogListParent()
                .environment(logVM)
        }
        .sheet($sheetSubdomains) {
            SubdomainList()
                .environment(subdomainVM)
        }
        .task {
            settingsVM.serverName = server.name
            settingsVM.serverDescription = server.description
            
            if !System.lowPowerMode {
                logVM.fetchLogs(true)
                userVM.fetchUsers(true)
                
                Task {
                    await subdomainVM.fetchSubdomains()
                }
            }
        }
    }
}

#Preview {
    InfoTabButtons(PreviewProp.serverAttributes)
}
