import SwiftUI

struct MyServicesList: View {
    @State private var servicesVM = MyServiceListVM()
    
    @Environment(BillingDashboardVM.self) private var vm
    
    var body: some View {
        List {
            MyServicesSection(title: "VDS", services: servicesVM.cloudServices.map { .cloud($0) }, isLoading: servicesVM.isCloudLoading) {
                VDSServiceDetailsTabView($0)
                    .environment(vm)
            }
            
            MyServicesSection(title: "Game servers", services: servicesVM.gameServices.map { .game($0) }, isLoading: servicesVM.isGameLoading) {
                ServiceDetailsView<GameServiceDetailsVM>($0)
                    .environment(vm)
            }
            
            MyServicesSection(title: "Bot hosting", services: servicesVM.botServices.map { .bot($0) }, isLoading: servicesVM.isBotLoading) {
                ServiceDetailsView<BotServiceDetailsVM>($0)
                    .environment(vm)
            }
        }
        .navigationTitle("My services")
        .environment(vm)
        .listStyle(.insetGrouped)
        .refreshableTask {
            await reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: .billingMyServicesShouldRefresh)) { _ in
            Task {
                await reload()
            }
        }
    }
    
    private func reload() async {
        await servicesVM.loadMyServices()
    }
}

#Preview {
    NavigationStack {
        MyServicesList()
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
