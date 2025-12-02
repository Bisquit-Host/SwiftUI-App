import SwiftUI

struct BillingHostingPlansView: View {
    @State private var vm = BillingHostingPlansVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    @EnvironmentObject private var store: ValueStore
    
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
                let plans = vm.plans(for: category, currency: preferredCurrencyCode, locationId: selectedLocationId)
                
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
                                priceText: vm.formattedPrice(for: plan, currency: preferredCurrencyCode),
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
                priceText: vm.formattedPrice(for: context.plan, currency: preferredCurrencyCode),
                vm: vm,
                preferredCurrency: preferredCurrencyCode
            )
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

private struct BillingPlanOrderContext: Identifiable, Equatable {
    let plan: BillingHostingPlan
    let category: BillingHostingCategory
    
    var id: String { "\(category.rawValue)-\(plan.id)" }
}

private struct BillingHostingOrderSheet: View {
    let context: BillingPlanOrderContext
    let priceText: String
    let vm: BillingHostingPlansVM
    let preferredCurrency: String?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var months = 1
    @State private var osCategories: [BillingCloudOsCategory] = []
    @State private var nests: [BillingHostingNest] = []
    @State private var selectedOsId = 0
    @State private var selectedNestId = 0
    @State private var selectedEggId = 0
    @State private var isLoadingOptions = false
    @State private var isOrdering = false
    @State private var message: String?
    @State private var error: String?
    
    init(context: BillingPlanOrderContext, priceText: String, vm: BillingHostingPlansVM, preferredCurrency: String?) {
        self.context = context
        self.priceText = priceText
        self.vm = vm
        self.preferredCurrency = preferredCurrency
        _name = State(initialValue: context.plan.name)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.plan.name)
                            .headline()
                        Text(priceText + " / mo")
                            .secondary()
                            .footnote()
                    }
                }
                
                Section("Configuration") {
                    TextField("Name", text: $name)
                        .textContentType(.nickname)
                    
                    Picker("Billing period", selection: $months) {
                        ForEach([1, 3, 6, 12], id: \.self) { value in
                            Text(monthLabel(value))
                                .tag(value)
                        }
                    }
                }
                
                if context.category == .cloud {
                    Section("Operating system") {
                        if isLoadingOptions && osItems.isEmpty {
                            ProgressView()
                        }
                        
                        Picker("OS", selection: $selectedOsId) {
                            ForEach(osItems, id: \.id) { item in
                                Text(item.title)
                                    .tag(item.id)
                            }
                        }
                    }
                } else {
                    Section("Template") {
                        if isLoadingOptions && nests.isEmpty {
                            ProgressView()
                        }
                        
                        Picker("Nest", selection: $selectedNestId) {
                            ForEach(nests) { nest in
                                Text(nest.name)
                                    .tag(nest.id)
                            }
                        }
                        
                        Picker("Egg", selection: $selectedEggId) {
                            ForEach(eggsForSelection) { egg in
                                Text(egg.name)
                                    .tag(egg.id)
                            }
                        }
                    }
                }
                
                if let message {
                    Section {
                        Label(message, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                if let error {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .textSelection(.enabled)
                    }
                }
                
                Section {
                    Button {
                        Task { await order() }
                    } label: {
                        if isOrdering {
                            ProgressView()
                        } else {
                            Text("Confirm purchase")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isOrdering || isLoadingOptions)
                }
            }
            .navigationTitle("Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await loadOptions()
            }
            .onChange(of: selectedNestId) { _, newValue in
                guard let nest = nests.first(where: { $0.id == newValue }) else { return }
                if let firstEgg = nest.eggs.first {
                    selectedEggId = firstEgg.id
                } else {
                    selectedEggId = 0
                }
            }
        }
    }
    
    private func loadOptions() async {
        guard !isLoadingOptions else { return }
        isLoadingOptions = true
        error = nil
        defer { isLoadingOptions = false }
        
        let options = await vm.loadOrderOptions(for: context.category, planId: context.plan.id)
        osCategories = options.osCategories
        nests = options.nests
        
        if selectedOsId == 0, let first = options.osCategories.first?.os.first {
            selectedOsId = first.id
        }
        if selectedNestId == 0, let first = options.nests.first {
            selectedNestId = first.id
        }
        if selectedEggId == 0, let first = options.nests.first?.eggs.first {
            selectedEggId = first.id
        }
        
        if context.category == .cloud && osCategories.isEmpty {
            error = vm.lastError ?? "Unable to load OS list"
        }
        
        if (context.category == .game || context.category == .bot), nests.isEmpty {
            error = vm.lastError ?? "No templates available"
        }
    }
    
    private func order() async {
        guard !isOrdering else { return }
        isOrdering = true
        error = nil
        message = nil
        defer { isOrdering = false }
        
        let response = await vm.order(
            plan: context.plan,
            category: context.category,
            name: name,
            months: months,
            osId: selectedOsId == 0 ? nil : selectedOsId,
            nestId: selectedNestId == 0 ? nil : selectedNestId,
            eggId: selectedEggId == 0 ? nil : selectedEggId
        )
        
        if let response {
            let formattedAmount = formatAmount(response.amount, code: preferredCurrency)
            message = "Purchased #\(response.serviceId). Charged \(formattedAmount)"
            
            Task {
                try? await Task.sleep(for: .seconds(1.2))
                dismiss()
            }
        } else {
            error = vm.lastError ?? "Unable to complete order"
        }
    }
    
    private var osItems: [(id: Int, title: String)] {
        osCategories.flatMap { category in
            category.os.map { item in
                let version = item.version.map { " \($0)" } ?? ""
                return (id: item.id, title: category.name + version)
            }
        }
    }
    
    private var eggsForSelection: [BillingHostingEgg] {
        nests.first { $0.id == selectedNestId }?.eggs ?? []
    }
    
    private func monthLabel(_ value: Int) -> String {
        value == 1 ? "1 month" : "\(value) months"
    }
    
    private func formatAmount(_ amount: Double, code: String?) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let value = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        
        guard let code else { return value }
        switch code.uppercased() {
        case "RUB": return "₽" + value
        case "EUR": return "€" + value
        case "USD": return "$" + value
        default: return value + " " + code.uppercased()
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
