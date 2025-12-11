import ScrechKit
import PteroNet

struct BillingDashboard: View {
    @State private var vm = BillingDashboardVM()
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var sheetSettings = false
    @State private var refreshTimerTask: Task<Void, Never>?
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BillingDashboardHostingLinks()
                    BillingDashboardNavLinks()
                }
                .padding()
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarBackButtonHidden()
        .refreshableTask {
            await vm.refreshAuthToken {
                print("Refreshed auth token")
            }
            
            await vm.fetchUserInfo()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                await vm.refreshAuthToken {
                    print("Refreshed auth token")
                }
                
                await vm.fetchUserInfo()
            }
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
                BillingSettings($vm.user)
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
    
    private func refreshAuthTokenIfNeeded() async {
        guard let lastRefresh = ValueStore().lastBillingTokenRefresh else {
            await vm.refreshAuthToken {
                print("Refreshed auth token")
            }
            
            return
        }
        
        let expiresInSeconds = TimeInterval(ValueStore().testExpiresIn) / 1000
        let expiryDate = lastRefresh.addingTimeInterval(expiresInSeconds)
        
        guard Date() >= expiryDate else { return }
        
        await vm.refreshAuthToken {
            print("Refreshed auth token")
        }
    }
}

#Preview {
    NavigationStack {
        BillingDashboard()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
