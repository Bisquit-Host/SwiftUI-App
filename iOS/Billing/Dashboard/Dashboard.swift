import ScrechKit
import PteroNet

struct Dashboard: View {
    @State private var vm = DashboardVM()
    @EnvironmentObject private var store: ValueStore
    
    @State private var sheetSettings = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
//                DashboardHostingLinks()
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
#warning("Disabled top-ups")
//            ToolbarItem(placement: .topBarLeading) {
//                if let user = vm.user {
//                    BillingDashboardBalance(user)
//                }
//            }
            
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
