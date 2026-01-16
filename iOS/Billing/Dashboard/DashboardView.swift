import ScrechKit
import PteroNet

struct DashboardView: View {
    @State private var vm = DashboardViewVM()
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var sheetSettings = false
    @State private var refreshTimerTask: Task<Void, Never>?
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DashboardViewHostingLinks()
                    DashboardViewNavLinks()
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .refreshableTask {
            refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            stopAuthRefreshTimer()
        }
        .onAppear(perform: startAuthRefreshTimer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                startAuthRefreshTimer()
            } else {
                stopAuthRefreshTimer()
            }
        }
        .sheet($sheetSettings) {
            NavigationStack {
                SettingsView($vm.user)
                    .environment(vm)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let user = vm.user {
                    BillingDashboardBalance(user)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("gear") {
                    sheetSettings = true
                }
            }
        }
        .animation(.default, value: vm.user)
        .environment(vm)
    }
    
    private func startAuthRefreshTimer() {
        guard refreshTimerTask == nil else { return }
        
        refreshTimerTask = Task {
            while !Task.isCancelled {
                await refreshAuthTokenIfNeeded()
                
                do {
                    try await Task.sleep(for: .seconds(60))
                } catch {
                    break
                }
            }
        }
    }
    
    private func stopAuthRefreshTimer() {
        refreshTimerTask?.cancel()
        refreshTimerTask = nil
    }
    
    private func refresh() {
        Task {
            await vm.refreshAuthToken {
                Logger().info("Refreshed auth token")
            }
            
            await vm.fetchUserInfo()
        }
    }
    
    private func refreshAuthTokenIfNeeded() async {
        guard let lastRefresh = ValueStore().lastBillingTokenRefresh else {
            await vm.refreshAuthToken {
                Logger().info("Refreshed auth token")
            }
            
            return
        }
        
        let expiresInSeconds = TimeInterval(ValueStore().accessTokenExpiresIn) / 1000
        let expiryDate = lastRefresh.addingTimeInterval(expiresInSeconds)
        
        guard Date() >= expiryDate else { return }
        
        await vm.refreshAuthToken {
            Logger().info("Refreshed auth token")
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
