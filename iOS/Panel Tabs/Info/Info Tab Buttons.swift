import ScrechKit
import PteroNet

struct InfoTabButtons: View {
    private var settingsVM: ServerSettingsVM
    private var logVM: LogVM
    private var userVM: UsersVM
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.settingsVM = ServerSettingsVM(server.id)
        self.logVM = LogVM(server.id)
        self.userVM = UsersVM(server.id)
    }
    
    @State private var sheetUsers = false
    @State private var sheetLogs = false
    
    var body: some View {
        VStack {
            InfoTabButton("Logs", icon: "list.bullet.rectangle.fill") {
                sheetLogs = true
            }
            .keyboardShortcut("L")
            
            Menu {
                Button {
                    sheetUsers = true
                    userVM.sheetInvitation = true
                } label: {
                    Label("New user", systemImage: "person.badge.plus")
                }
            } label: {
                HStack {
                    Text("Users")
                        .rounded()
                    
                    Spacer()
                    
                    Image(systemName: "person.3.fill")
                        .title2()
                }
                .frame(height: 25)
                .foregroundStyle(.foreground)
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            } primaryAction: {
                sheetUsers = true
            }
            .keyboardShortcut("U")
            
            Spacer()
                .frame(height: 20)
            
#if canImport(ActivityKit)
            InfoTabLAButton(server)
#endif
        }
        .sheet($sheetUsers) {
            UserListParent()
                .environment(userVM)
        }
        .sheet($sheetLogs) {
            LogListParent()
                .environment(logVM)
        }
        .task {
            settingsVM.serverName = server.name
            settingsVM.serverDescription = server.description
            
            if !System.lowPowerMode {
                logVM.fetchLogs(true)
                userVM.fetchUsers(true)
            }
        }
    }
}

#Preview {
    InfoTabButtons(PreviewProp.serverAttributes)
}
