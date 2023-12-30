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
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.settingsVM = ServerSettingsVM(server.id)
        self.logVM = LogVM(server.id)
        self.userVM = UsersVM(server.id)
    }
    
    @State private var sheetSettings = false
    @State private var sheetUsers = false
    @State private var sheetLogs = false
    @State private var sheetAllocations = false
    @State private var isRotating = false
    
    var body: some View {
        @Bindable var binding = settingsVM
        
        VStack {
            HStack {
                InfoTabButton("Logs", icon: "list.bullet.rectangle.fill") {
                    sheetLogs = true
                }
                
                Button {
                    sheetSettings = true
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
                    sheetAllocations = true
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
            settingsVM.serverName = server.name
            settingsVM.serverDescription = server.description
        }
        .sheet($sheetSettings) {
            PanelSettingsParent(server)
        }
        .sheet($sheetUsers) {
            UserListParent()
                .environment(userVM)
        }
        .sheet($sheetAllocations) {
            AllocationListParent(server)
        }
        .sheet($sheetLogs) {
            LogListParent()
                .environment(logVM)
        }
    }
}

#Preview {
    InfoTabButtons(
        sampleJSON(.serverListAttributes)
    )
}
