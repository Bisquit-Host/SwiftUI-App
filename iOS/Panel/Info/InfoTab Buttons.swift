import ScrechKit
import PteroNet

struct InfoTabButtons: View {
#if canImport(ActivityKit)
    private var liveActivity = LiveActivity()
#endif
    
    private var settingsVM: ServerSettingsVM
    private var logVM: LogVM
    private var userVM: UsersVM
    private let server: ServerAttributes
    @EnvironmentObject private var settings: SettingsStorage
    
    init(_ server: ServerAttributes,
         modelRename: ServerSettingsVM = ServerSettingsVM(""),
         logVM: LogVM = LogVM(""),
         modelUsers: UsersVM = UsersVM("")
    ) {
        self.server = server
        self.settingsVM = ServerSettingsVM(server.id)
        self.logVM = LogVM(server.id)
        self.userVM = UsersVM(server.id)
    }
    
    @State private var sheetSftp = false
    @State private var sheetUsers = false
    @State private var sheetLogs = false
    @State private var sheetStartup = false
    @State private var isRotating = false
    @State private var alertReinstall = false
    
    var body: some View {
        @Bindable var binding = settingsVM
        
        VStack {
            HStack {
                InfoTabButton("Logs", icon: "list.bullet.rectangle.fill") {
                    sheetLogs = true
                }
                
                Menu {
                    MenuButton("Rename server", icon: "pencil") {
                        settingsVM.alertRename = true
                    }
                    
                    MenuButton("SFTP Credentials", icon: "doc.viewfinder") {
                        sheetSftp = true
                    }
#if DEBUG
                    MenuButton("Startup", icon: "airplane") {
                        sheetStartup = true
                    }
#endif
                    
                    Section {
                        MenuButton("Reinstall", role: .destructive, icon: "arrow.triangle.2.circlepath") {
                            alertReinstall = true
                        }
                    }
                } label: {
                    Image(systemName: "gear")
                        .title2(.semibold)
                        .rotate(isRotating ? 360 : 0)
                        .animation(
                            .linear(duration: 60)
                            .repeatForever(autoreverses: false),
                            value: isRotating
                        )
                        .frame(height: 25)
                        .padding()
                        .background(.ultraThinMaterial,
                                    in: .rect(cornerRadius: 16)
                        )
                        .onAppear {
                            isRotating = true
                        }
                }
            }
            
            HStack {
                Button("IP") {
                    withAnimation {
                        settings.last_tab_panel_info = .ip
                    }
                }
                .padding()
                .title2(.semibold)
                .foregroundStyle(.primary)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                
                InfoTabButton("Users", icon: "person.3.fill") {
                    sheetUsers = true
                }
            }
            
#if canImport(ActivityKit)
            switch liveActivity.activityViewState?.activityState {
            case .active:
                Button {
                    liveActivity.stopAllLiveActivities()
                } label: {
                    Text("Cancel")
                        .rounded()
                        .title2(.semibold)
                        .foregroundStyle(.red)
                        .frame(height: 25)
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                }
                
            default:
                Button {
                    liveActivity.stopAllLiveActivities()
                    liveActivity.startLiveActivity(server)
                } label: {
                    Text("Live Activity (BETA)")
                        .title2(.semibold, design: .rounded)
                        .foregroundStyle(.foreground)
                        .frame(height: 25)
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                }
            }
#endif
        }
        .task {
            logVM.fetchLogs()
            userVM.fetchUsers()
            settingsVM.fetchStartupVariables()
            settingsVM.serverName = server.name
            settingsVM.serverDescription = server.description
        }
        .sheet($sheetSftp) {
            SftpView(server)
        }
        .sheet($sheetUsers) {
            UserList()
                .environment(userVM)
        }
        .sheet($sheetStartup) {
            StartupView(server)
                .environment(settingsVM)
        }
        .sheet($sheetLogs) {
            LogListParent()
                .environment(logVM)
        }
        .alert("Reinstall Server", isPresented: $alertReinstall) {
            Button("Reinstall", role: .destructive) {
                PteroNet.reinstallServer(server.id)
            }
        } message: {
            Text("Reinstalling your server will stop it, and then re-run the installation script that initially set it. Some files may be deleted or modified during this process, please back up your data before continuing")
        }
        .alert("Rename server", isPresented: $binding.alertRename) {
            TextField("Name", text: $binding.serverName)
                .autocorrectionDisabled()
            
            TextField("Description", text: $binding.serverDescription)
                .autocorrectionDisabled()
            
            Button("Rename", role: .destructive) {
                settingsVM.serverRename()
            }
        }
    }
}

#Preview {
    InfoTabButtons(
        sampleJSON(.serverListAttributes)
    )
}
