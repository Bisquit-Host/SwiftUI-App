import SwiftUI

struct MyServicesList: View {
    @State private var servicesVM = MyServiceListVM()
    
    @Environment(DashboardVM.self) private var vm
    
    var body: some View {
        List {
            MyServicesSection(title: "My services", services: servicesVM.services, isLoading: servicesVM.isLoading) { service in
                BillingMyServiceDestinationView(service)
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
            .environment(DashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
