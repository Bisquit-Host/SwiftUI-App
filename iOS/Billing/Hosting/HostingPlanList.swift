import SwiftUI

struct HostingPlanList: View {
    @State private var vm = HostingPlanListVM()
    
    @State private var category: BillingHostingCategory
    
    init(_ defaultCategory: BillingHostingCategory = .game) {
        _category = State(initialValue: defaultCategory)
    }
    
    @State private var selectedLocations: [BillingHostingCategory: Int] = [:]
    @State private var orderContext: BillingPlanOrderContext?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HostingPlanListServicePicker($category)
                
                let locations = vm.locations(for: category)
                let selectedLocationId = selectedLocationId(for: category, available: locations)
                let plans = vm.plans(for: category, currency: nil, locationId: selectedLocationId)
                
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
        .navigationSubtitle(category.description)
        .environment(vm)
        .scrollIndicators(.never)
        .background(.background.opacity(0.9))
        .refreshableTask {
            await vm.loadAll()
        }
        .sheet(item: $orderContext) { context in
            HostingOrderSheet(context: context, priceText: vm.formattedPrice(for: context.plan, currency: nil), vm: vm)
        }
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
    .environment(BillingDashboardVM())
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
