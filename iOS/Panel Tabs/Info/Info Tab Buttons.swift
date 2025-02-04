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
    @EnvironmentObject private var settings: ValueStorage
    
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
    
    private let lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    var body: some View {
        VStack {
            HStack {
                InfoTabButton("Logs", icon: "list.bullet.rectangle.fill") {
                    sheetLogs = true
                }
                .keyboardShortcut("L")
                
                Button {
                    sheetSettings = true
                } label: {
                    Image(systemName: "gear")
                        .foregroundStyle(.accent.gradient)
                        .title2(.semibold)
                        .rotate(isRotating ? 360 : 0)
                        .animation(
                            .linear(duration: 60)
                            .repeatForever(autoreverses: false),
                            value: isRotating
                        )
                        .frame(height: 25)
                        .padding()
                        .background(.ultraThinMaterial,in: .rect(cornerRadius: 16))
                        .onAppear {
                            isRotating = true
                        }
                }
                .keyboardShortcut("S")
            }
            
            HStack {
                Button("IP") {
                    sheetAllocations = true
                }
                .padding()
                .title2(.semibold)
                .foregroundStyle(.primary)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                .keyboardShortcut("I")
                
                InfoTabButton("Users", icon: "person.3.fill") {
                    sheetUsers = true
                }
                .keyboardShortcut("U")
            }
            
            Spacer()
                .frame(height: 20)
            
#if canImport(ActivityKit)
            if liveActivity.activityViewState?.activityState == .active {
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
            } else {
                Button {
                    liveActivity.stopAllLiveActivities()
                    liveActivity.startLiveActivity(server)
                } label: {
                    Text("Live Activity")
                        .title2(.semibold, design: .rounded)
                        .foregroundStyle(.foreground)
                        .frame(height: 25)
                        .padding()
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                }
                .overlay(alignment: .topTrailing) {
                    Text("Beta")
                        .rounded()
                        .footnote(.bold)
                        .foregroundStyle(.white.gradient)
                        .padding(.horizontal, 4)
                        .background(.blue.gradient, in: .capsule)
                        .padding(-6)
                }
            }
#endif
        }
        .task {
            settingsVM.serverName = server.name
            settingsVM.serverDescription = server.description
            
            if !lowPowerMode {
                logVM.fetchLogs()
                userVM.fetchUsers()
            }
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
    InfoTabButtons(PreviewProperty.serverAttributes)
}
