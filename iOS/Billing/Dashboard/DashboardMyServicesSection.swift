import SwiftUI

struct DashboardMyServicesSection: View {
    @State private var servicesVM = MyServiceListVM()
    @State private var operationsVM = SheetTopupVM()
    
    var body: some View {
        BillingSectionCard("My services", showsBackground: false) {
            if (servicesVM.isLoading && servicesVM.services.isEmpty) || (operationsVM.isLoading && operationsVM.operations.isEmpty) {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                
            } else if servicesVM.services.isEmpty && operationsVM.operations.isEmpty {
                DashboardTestAccessRequestView()
                
            } else if servicesVM.services.isEmpty {
                Text("No services yet")
                    .secondary()
                    .footnote()
            } else {
                ForEach(servicesVM.services, id: \.listID) {
                    MyServiceCard($0)
                }
            }
        }
        .task {
            await reload()
        }
        .task {
            for await _ in NotificationCenter.default.notifications(named: .billingMyServicesShouldRefresh) {
                await reload()
            }
        }
    }
    
    private func reload() async {
        async let services: () = servicesVM.loadMyServices()
        async let operations: () = operationsVM.fetchOperations()
        
        let _ = await (services, operations)
    }
}

#Preview {
    NavigationStack {
        DashboardMyServicesSection()
            .environment(DashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
