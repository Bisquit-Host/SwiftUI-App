import SwiftUI

struct BillingMyServicesView: View {
    @State private var cloudVM = BillingCloudServicesVM()
    @State private var gameVM = BillingGameServicesVM()
    @State private var botVM = BillingBotServicesVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    var body: some View {
        List {
            section("VDS", services: cloudVM.services.map { .cloud($0) }, isLoading: cloudVM.isLoading, error: cloudVM.lastError) {
                BillingCloudServiceDetailView(serviceId: $0)
                    .environment(dashboardVM)
            }
            
            section("Game servers", services: gameVM.services.map { .game($0) }, isLoading: gameVM.isLoading, error: gameVM.lastError) { id in
                BillingGameServiceDetailView(serviceId: id)
                    .environment(dashboardVM)
            }
            
            section("Bot hosting", services: botVM.services.map { .bot($0) }, isLoading: botVM.isLoading, error: botVM.lastError) { id in
                BillingBotServiceDetailView(serviceId: id)
                    .environment(dashboardVM)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("My services")
        .refreshableTask {
            await cloudVM.loadServices()
            await gameVM.loadServices()
            await botVM.loadServices()
        }
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private func section(_ title: String, services: [BillingAnyService], isLoading: Bool, error: String?, detail: @escaping (Int) -> some View) -> some View {
        Section(title) {
            if isLoading && services.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if let error {
                Text(error)
                    .foregroundStyle(.red)
                    .footnote()
            }
            
            if services.isEmpty && !isLoading {
                Text("No services yet")
                    .secondary()
                    .footnote()
            } else {
                ForEach(services) { item in
                    NavigationLink {
                        detail(item.id)
                    } label: {
                        BillingServiceRow(item)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BillingMyServicesView()
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
