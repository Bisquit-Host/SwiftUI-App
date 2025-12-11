import SwiftUI

struct BillingMyServicesList: View {
    @State private var cloudVM = BillingCloudServicesVM()
    @State private var gameVM = GameServiceListVM()
    @State private var botVM = BotServicesListVM()
    @Environment(BillingDashboardVM.self) private var vm
    
    var body: some View {
        List {
            BillingMyServicesSection("VDS", services: cloudVM.services.map { .cloud($0) }, isLoading: cloudVM.isLoading) {
                VDSServiceDetails(serviceId: $0)
                    .environment(vm)
            }
            
            BillingMyServicesSection("Game servers", services: gameVM.services.map { .game($0) }, isLoading: gameVM.isLoading) {
                GameServiceDetails(serviceId: $0)
                    .environment(vm)
            }
            
            BillingMyServicesSection("Bot hosting", services: botVM.services.map { .bot($0) }, isLoading: botVM.isLoading) {
                BotServiceDetails(serviceId: $0)
                    .environment(vm)
            }
        }
        .navigationTitle("My services")
        .listStyle(.insetGrouped)
        .refreshableTask {
            async let cloud: () = cloudVM.loadServices()
            async let game: () = gameVM.loadServices()
            async let bot: () = botVM.loadServices()
            
            let _ = await (cloud, game, bot)
        }
    }
}

#Preview {
    NavigationStack {
        BillingMyServicesList()
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
