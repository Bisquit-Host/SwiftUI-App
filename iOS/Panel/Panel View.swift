import ScrechKit
import PteroNet

struct PanelView: View {
    @EnvironmentObject private var settings: SettingsStorage
    private var vm: PanelVM
    private var fileVM: FileTabVM
    private var backupVM: BackupVM
    private var databaseVM: DatabaseVM
    private var scheduleVM: ScheduleVM
    private var startupVM: StartupVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.backupVM = BackupVM(id)
        self.databaseVM = DatabaseVM(id)
        self.scheduleVM = ScheduleVM(id)
        self.vm = PanelVM(id)
        self.fileVM = FileTabVM(id)
        self.startupVM = StartupVM(id)
    }
    
    @State private var allTabs: [AnimatedTab] = Tabs.allCases.compactMap { tab -> AnimatedTab? in
            .init(tab: tab)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $settings.lastTabPanel) {
                if let server = vm.server {
                    InfoTab(server)
                        .environment(vm)
                        .setUpTab(.info, isAnimated: settings.animatedTabbar)
                    
                    ConsoleTab(id)
                        .setUpTab(.console, isAnimated: settings.animatedTabbar)
                    
                    FileTab(id)
                        .environmentObject(fileVM)
                        .setUpTab(.files, isAnimated: settings.animatedTabbar)
                    
                    DataTab(id, limits: server.featureLimits)
                        .environment(backupVM)
                        .environment(databaseVM)
                        .environment(scheduleVM)
                        .setUpTab(.backup, isAnimated: settings.animatedTabbar)
                    
                    StartupView(server)
                        .environment(startupVM)
                        .setUpTab(.startup, isAnimated: settings.animatedTabbar)
                }
            }
            
            if settings.animatedTabbar {
                CustomTabBar()
            }
        }
        .environment(vm)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .task {
            vm.fetchServerDetails()
            
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
            
            fileVM.fetchFiles()
            backupVM.fetchBackups()
            databaseVM.fetchDatabases()
            scheduleVM.fetchSchedules()
            startupVM.fetchStartupVariables()
            
            vm.updateBackups = {
                backupVM.fetchBackups()
            }
        }
        .onDisappear {
            vm.disconnectWebSocket()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            vm.disconnectWebSocket()
            vm.messages.removeAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            vm.consoleDetails { data in
                if let data {
                    vm.connectWebSocket(data)
                }
            }
        }
    }
    
    @ViewBuilder
    func CustomTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach($allTabs) { $animatedTab in
                let tab = animatedTab.tab
                
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .title()
                        .symbolEffect(settings.tabViewBouncesDown ? .bounce.down.byLayer : .bounce.up.byLayer, value: animatedTab.isAnimating)
                    
                    Text(tab.title)
                        .caption2()
                        .textScale(.secondary)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(settings.lastTabPanel == tab ? Color.primary : .gray.opacity(0.8))
                .padding(.top, 15)
                .padding(.bottom, 10)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.bouncy, completionCriteria: .logicallyComplete) {
                        settings.lastTabPanel = tab
                        animatedTab.isAnimating = true
                        
                    } completion: {
                        var trasnaction = Transaction()
                        trasnaction.disablesAnimations = true
                        
                        withTransaction(trasnaction) {
                            animatedTab.isAnimating = nil
                        }
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
    }
}

#Preview {
    PanelView("")
        .environment(PanelVM(""))
        .environment(BackupVM(""))
        .environment(DatabaseVM(""))
        .environment(ScheduleVM(""))
        .environmentObject(FileTabVM(""))
        .environmentObject(SettingsStorage())
}
