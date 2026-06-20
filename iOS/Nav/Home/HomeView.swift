import AppIntents
import ScrechKit

#if os(iOS)
struct HomeView: View {
    @State private var securityTasks = SecurityTasks()
    @State private var dashboardVM = DashboardVM()
    @State private var sheetSettings = false
    @State private var sheetTopup = false
    @State private var preselectedTopupProviderID: String?
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        @Bindable var nav = nav
        @Bindable var dashboardVM = dashboardVM
        
        NavigationStack(path: $nav.path) {
            Group {
                if store.accessToken?.isEmpty ?? true {
                    LoginView()
                } else {
                    TabView(selection: $store.homeSelectedTab) {
                        Tab("Billing", systemImage: "creditcard", value: .billing) {
                            HomeTabView()
                        }
                        
                        Tab("Pterodactyl", systemImage: "externaldrive", value: .pterodactyl) {
                            PterodactylHomeView()
                        }
                    }
                }
            }
            .withNavDestinations()
            .toolbar {
                if showsBillingToolbar, let user = dashboardVM.user {
                    ToolbarItem(placement: .topBarLeading) {
                        BillingDashboardBalance(user) {
                            preselectedTopupProviderID = nil
                            sheetTopup = true
                        }
                    }
                }
                
                if showsBillingToolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        SFButton("gear") {
                            sheetSettings = true
                        }
                    }
                }
            }
        }
        .environment(dashboardVM)
        .sheet($sheetSettings) {
            NavigationStack {
                SettingsView($dashboardVM.user)
                    .environment(dashboardVM)
            }
        }
        .sheet($sheetTopup) {
            NavigationStack {
                if let user = dashboardVM.user {
                    SheetTopup(user, preselectedProviderID: preselectedTopupProviderID)
                } else {
                    ProgressView()
                        .navigationTitle("Finance stuff")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .onAppIntentExecution(OpenBalanceTopupIntent.self) {
            preselectedTopupProviderID = $0.target.id
            sheetTopup = true
            refreshBillingUser()
        }
        .task {
            handlePendingHomeScreenQuickAction()
        }
        .task {
            for await _ in NotificationCenter.default.notifications(named: HomeScreenQuickAction.topupNotification) {
                showTopupFromQuickAction()
            }
        }
        .animation(.default, value: dashboardVM.user)
        .environment(securityTasks)
        .onFirstAppear {
            await securityTasks.startCheck()
        }
        .fullScreenCover($securityTasks.alertUpdate) {
            UpdateSheet()
        }
    }
    
    private var showsBillingToolbar: Bool {
        !(store.accessToken?.isEmpty ?? true)
    }
    
    private func refreshBillingUser() {
        Task {
            await dashboardVM.fetchUserInfo {
                _ = deleteBillingSessionToken()
                store.accessToken = nil
                store.updateAccessToken()
            }
        }
    }
    
    private func handlePendingHomeScreenQuickAction() {
        guard let shortcutItem = AppDelegate.pendingShortcutItem else {
            return
        }
        
        AppDelegate.pendingShortcutItem = nil
        
        guard HomeScreenQuickAction.isTopup(shortcutItem) else {
            return
        }
        
        showTopupFromQuickAction()
    }
    
    private func showTopupFromQuickAction() {
        guard showsBillingToolbar else {
            return
        }
        
        store.homeSelectedTab = .billing
        preselectedTopupProviderID = nil
        sheetTopup = true
        refreshBillingUser()
    }
}

#Preview {
    HomeView()
        .environment(NavState())
        .environmentObject(ValueStore())
}
#endif
