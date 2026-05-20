import SwiftUI

struct DashboardMyServicesSection: View {
    @State private var servicesVM = MyServiceListVM()
    @Environment(DashboardVM.self) private var vm
    
    var body: some View {
        BillingSectionCard("My services", showsBackground: false) {
            VStack(spacing: 12) {
                if servicesVM.isLoading && servicesVM.services.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if servicesVM.services.isEmpty && !servicesVM.isLoading {
                    Text("No services yet")
                        .secondary()
                        .footnote()
                } else {
                    ForEach(servicesVM.services, id: \.listID) { service in
                        NavigationLink {
                            BillingMyServiceDestinationView(service)
                                .environment(vm)
                        } label: {
                            MyServiceCard(service)
                                .environment(vm)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .task {
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
        DashboardMyServicesSection()
            .environment(DashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
