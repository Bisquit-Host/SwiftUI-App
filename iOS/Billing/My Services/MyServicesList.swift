import SwiftUI

struct MyServicesList: View {
    @State private var cloudVM = VDSBillingVM()
    @State private var gameVM = GameServiceListVM()
    @State private var botVM = BotServiceListVM()
    @Environment(BillingDashboardVM.self) private var vm
    
    var body: some View {
        List {
            MyServicesSection(title: "VDS", services: cloudVM.services.map { .cloud($0) }, isLoading: cloudVM.isLoading) {
                VDSServiceDetailsTabView($0)
                    .environment(vm)
            }
            
            MyServicesSection(title: "Game servers", services: gameVM.services.map { .game($0) }, isLoading: gameVM.isLoading) {
                ServiceDetailsView<GameServiceDetailsVM>($0)
                    .environment(vm)
            }
            
            MyServicesSection(title: "Bot hosting", services: botVM.services.map { .bot($0) }, isLoading: botVM.isLoading) {
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
        async let cloud: () = cloudVM.loadMyCloudServices()
        async let game: () = gameVM.fetchMyGameServices()
        async let bot: () = botVM.fetchMyBotServices()
        
        let _ = await (cloud, game, bot)
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
