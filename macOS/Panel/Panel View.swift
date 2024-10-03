import ScrechKit
import PteroNet

struct PanelView: View {
    private var vm: PanelVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = PanelVM(server.id)
    }
    
    @AppStorage("selected_tab") private var selectedTab: Tab = .info
    
    private let gradient = Gradient(colors: [Color(0xf7b948), Color(0xed5547), Color(0x893799)])
    private let tabs: [Tab] = [
        //        .info,
        //        .console,
        //        .files,
        .backups,
        //        .schedules,
        .databases,
        .users,
        //        .allocations,
        //        .startup,
        //        .settings,
            .logs,
        //        .admin
    ]
    
#if os(macOS)
    let application = NSApplication.self
#else
    let application = UIApplication.self
#endif
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text(tab.rawValue)
                                .title2(.semibold, design: .rounded)
                                .padding(10)
                                .foregroundStyle(selectedTab == tab ? .yellow : .primary)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding()
            }
            
            Group {
                switch selectedTab {
                case .console:
                    ConsoleView(server.id)
                        .environment(vm)
                    
                case .files:
                    FileTab(server.id)
                    
                case .backups:
                    BackupList(server)
                    
                case .databases:
                    DatabaseList(server.id)
                    
                case .schedules:
                    ScheduleList(server.id)
                    
                case .allocations:
                    AllocationList(server.id)
                    
                case .users:
                    UserList(server.id)
                    
                case .startup:
                    StartupList(server.id)
                    
                case .logs:
                    LogList(server.id)
                    
                default:
                    Spacer()
                    
                    Text("\(selectedTab.rawValue) will be availible soon...")
                        .largeTitle()
                    
                    Spacer()
                }
            }
            .id(server.id)
        }
        .offset(y: -30)
        .background {
            ZStack {
#if os(macOS)
                BackgroundBlur()
#endif
                HStack {
                    Rectangle()
                        .fill(gradient)
                        .opacity(0.3)
                }
            }
            .ignoresSafeArea()
        }
        .task {
            vm.fetchServerDetails()
            
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
        }
        .onChange(of: server.id) {
            vm.fetchServerDetails()
            
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
        .onReceive(NotificationCenter.default.publisher(for: application.willResignActiveNotification)) { _ in
            vm.disconnectWebSocket()
            vm.messages.removeAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: application.didBecomeActiveNotification)) { _ in
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
        }
    }
}

#Preview {
    PanelView(sampleJSON(.serverListAttributes))
        .environmentObject(SettingsStorage())
}
