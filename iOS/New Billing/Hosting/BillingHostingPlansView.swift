import SwiftUI

struct BillingHostingPlansView: View {
    @State private var vm = BillingHostingPlansVM()
    
    @State private var category: BillingHostingCategory
    @State private var selectedLocations: [BillingHostingCategory: Int] = [:]
    @State private var orderContext: BillingPlanOrderContext?
    
    init(defaultCategory: BillingHostingCategory = .game) {
        _category = State(initialValue: defaultCategory)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Service", selection: $category) {
                    ForEach(BillingHostingCategory.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                let locations = vm.locations(for: category)
                let selectedLocationId = selectedLocationId(for: category, available: locations)
                let plans = vm.plans(for: category, currency: nil, locationId: selectedLocationId)
                
                if !locations.isEmpty {
                    locationSelector(for: category, locations: locations, selectedLocationId: selectedLocationId)
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
                            BillingHostingPlanCard(
                                plan: plan,
                                priceText: vm.formattedPrice(for: plan, currency: nil),
                                category: category
                            ) {
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
        .background(.background.opacity(0.9))
        .refreshableTask {
            await vm.loadAll()
        }
        .toolbar {
            if vm.isLoading {
                ProgressView()
            } else if let error = vm.lastError {
                Text(error)
                    .footnote()
                    .secondary()
            }
        }
        .sheet(item: $orderContext) { context in
            BillingHostingOrderSheet(
                context: context,
                priceText: vm.formattedPrice(for: context.plan, currency: nil),
                vm: vm
            )
        }
    }
    
    private func selectedLocationId(for category: BillingHostingCategory, available locations: [BillingHostingLocation]) -> Int? {
        if let id = selectedLocations[category], locations.contains(where: { $0.id == id }) {
            return id
        }
        
        return locations.first?.id
    }
    
    @ViewBuilder
    private func locationSelector(for category: BillingHostingCategory, locations: [BillingHostingLocation], selectedLocationId: Int?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .footnote()
                .secondary()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(locations) { location in
                        locationChip(location, isSelected: selectedLocationId == location.id) {
                            selectLocation(location.id, for: category)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.primary.opacity(0.04), lineWidth: 1)
        }
    }
    
    private func locationChip(_ location: BillingHostingLocation, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let flag = location.flagUrl, let url = URL(string: flag) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.15)
                    }
                    .frame(width: 28, height: 18)
                    .clipShape(.rect(cornerRadius: 5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.primary.opacity(0.08), lineWidth: 1)
                    }
                }
                
                Text(location.name)
                    .footnote()
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.systemBackground).opacity(0.6))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor.opacity(0.4) : Color.primary.opacity(0.05), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
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
        BillingHostingPlansView()
    }
    .environment(BillingDashboardVM())
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
