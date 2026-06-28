import ScrechKit

struct Dashboard: View {
    @State private var ticketVM = TicketListVM()
    @Environment(DashboardVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                DashboardMyServicesSection()
                DashboardAvailableServices()
                
                DashboardActiveTicketsSection()
                    .environment(ticketVM)
                
                DashboardSupportSection()
                    .environment(ticketVM)
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
        .animation(.default, value: vm.user)
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
    .environment(DashboardVM())
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
