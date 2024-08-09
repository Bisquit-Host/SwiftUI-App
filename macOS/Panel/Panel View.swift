import ScrechKit

struct PanelView: View {
    private var vm: PanelVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = PanelVM(id)
    }
    
    @AppStorage("selected_tab") private var selectedTab: Tab = .info
    
    private let gradient = Gradient(colors: [Color(0xf7b948), Color(0xed5547), Color(0x893799)])
    private let tabs: [Tab] = [
        //        .info,
        //        .console,
        //        .files,
        //        .plugins,
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
                    ConsoleView(id)
                        .environment(vm)
                    
                case .files:
                    FileTab(id)
                    
                case .plugins:
                    PluginList(id)
                    
                case .backups:
                    if let server = vm.server {
                        BackupList(server)                        
                    }
                    
                case .databases:
                    DatabaseList(id)
                    
                case .schedules:
                    ScheduleList(id)
                    
                case .allocations:
                    AllocationList(id)
                    
                case .users:
                    UserList(id)
                    
                case .startup:
                    StartupList(id)
                    
                case .logs:
                    LogList(id)
                    
                default:
                    Spacer()
                    
                    Text("\(selectedTab.rawValue) will be availible soon...")
                        .largeTitle()
                    
                    Spacer()
                }
            }
            .id(id)
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
        .onChange(of: id) {
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
    PanelView("")
        .environmentObject(SettingsStorage())
}
