import ScrechKit
import PteroNet
import BisquitoNet
import AppIntents

struct Dashboard: View {
    @State private var vm = DashboardVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    @State private var sheetTopup = false
    @State private var preselectedTopupProviderID: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                DashboardAvailableServices()
                DashboardMyServicesSection()
                DashboardActiveTicketsSection()
                
                VStack(spacing: 16) {
                    DashboardPterodactylSection()
                    DashboardSupportSection()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .scrollIndicators(.never)
        .refreshableTask {
            refresh()
        }
        .task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                refresh()
            }
        }
        .sheet($sheetSettings) {
            NavigationStack {
                SettingsView($vm.user)
                    .environment(vm)
            }
        }
        .sheet($sheetTopup) {
            NavigationStack {
                if let user = vm.user {
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
            refresh()
        }
        .toolbar {
            if let user = vm.user {
                ToolbarItem(placement: .topBarLeading) {
                    BillingDashboardBalance(user) {
                        preselectedTopupProviderID = nil
                        sheetTopup = true
                    }
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
    
    private func refresh() {
        Task {
            await vm.fetchUserInfo {
                _ = deleteBillingSessionToken()
                store.accessToken = nil
                store.updateAccessToken()
            }
        }
    }
}

#Preview {
    NavigationStack {
        Dashboard()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
