import ScrechKit
import PteroNet
import BisquitoNet

struct Dashboard: View {
    @State private var vm = DashboardVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let user = vm.user, areTopupsAvailable(user) {
                    DashboardHostingLinks()
                }
                
                DashboardMyServicesSection()
                DashboardActiveTicketsSection()
                DashboardNavLinks()
            }
        }
        .navigationBarBackButtonHidden()
        .refreshableTask {
            refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            refresh()
        }
        .sheet($sheetSettings) {
            NavigationStack {
                SettingsView($vm.user)
                    .environment(vm)
            }
        }
        .toolbar {
            if let user = vm.user, areTopupsAvailable(user) {
                ToolbarItem(placement: .topBarLeading) {
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
