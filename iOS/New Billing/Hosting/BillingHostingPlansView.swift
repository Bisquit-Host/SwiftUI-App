import SwiftUI

struct BillingHostingPlansView: View {
    @State private var vm = BillingHostingPlansVM()
    @EnvironmentObject private var store: ValueStore
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    @State private var category: BillingHostingCategory
    
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
                .padding(16)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.primary.opacity(0.04), lineWidth: 1)
                }
                
                let plans = vm.plans(for: category, currency: preferredCurrencyCode)
                
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
                        ForEach(plans) {
                            BillingHostingPlanCard(
                                $0,
                                location: vm.location(for: $0, in: category),
                                priceText: vm.formattedPrice(for: $0, currency: preferredCurrencyCode),
                                category: category
                            )
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
    }
    
    private var preferredCurrencyCode: String? {
        if let userCurrency = dashboardVM.user?.currency, !userCurrency.isEmpty {
            return userCurrency.uppercased()
        }
        
        switch store.preferredCurrency {
        case "₽": return "RUB"
        case "€": return "EUR"
        default: return nil
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
