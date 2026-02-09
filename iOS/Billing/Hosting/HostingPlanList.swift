import SwiftUI

struct HostingPlanList: View {
    @State private var vm = HostingPlanListVM()
    @Environment(DashboardViewVM.self) private var dashboardVM
    
    @State private var category: BillingHostingCategory
    
    init(_ сategory: BillingHostingCategory = .game) {
        _category = State(initialValue: сategory)
    }
    
    @State private var selectedLocations: [BillingHostingCategory: Int] = [:]
    @State private var orderContext: BillingPlanOrderContext?
    
    var body: some View {
        let currencyCode = dashboardVM.user?.currency.rawValue
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HostingPlanListServicePicker($category)
                
                let locations = vm.locations(for: category)
                let selectedLocationId = selectedLocationId(for: category, available: locations)
                let plans = vm.plans(for: category, currency: currencyCode, locationId: selectedLocationId)
                
                if !locations.isEmpty {
                    LocationSelector(locations, selectedLocationId: selectedLocationId) {
                        selectLocation($0, for: category)
                    }
                }
                
                if vm.isLoading && plans.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                    
                } else if plans.isEmpty {
                    ContentUnavailableView("No plans yet", systemImage: "shippingbox")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    
                } else {
                    VStack(spacing: 12) {
                        ForEach(plans) { plan in
                            HostingPlanCard(plan, in: category) {
                                orderContext = BillingPlanOrderContext(plan: plan, category: category)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category.title)
        .navSubtitle(category.description)
        .scrollIndicators(.never)
        .background(.background.opacity(0.9))
        .refreshableTask {
            await vm.loadAll(currency: dashboardVM.user?.currency)
        }
        .onChange(of: dashboardVM.user?.currency) { _, newValue in
            guard let newValue else { return }
            
            Task {
                await vm.loadAll(currency: newValue)
            }
        }
        .sheet(item: $orderContext) { context in
            NavigationStack {
                HostingOrderSheet(context: context, priceText: vm.formattedPrice(for: context.plan, currency: currencyCode))
            }
        }
        .environment(vm)
        .toolbar {
            if vm.isLoading {
                ProgressView()
            }
        }
    }
    
    private func selectedLocationId(for category: BillingHostingCategory, available locations: [HostingLocation]) -> Int? {
        if let id = selectedLocations[category], locations.contains(where: { $0.id == id }) {
            return id
        }
        
        return locations.first?.id
    }
    
    private func selectLocation(_ id: Int?, for category: BillingHostingCategory) {
        if let id {
            selectedLocations[category] = id
        } else {
            selectedLocations.removeValue(forKey: category)
        }
    }
}

#Preview {
    NavigationStack {
        HostingPlanList()
    }
    .environment(DashboardViewVM())
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
