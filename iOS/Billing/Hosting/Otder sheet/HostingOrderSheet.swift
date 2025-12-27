import SwiftUI

struct HostingOrderSheet: View {
    @State private var confetti = ConfettiVM()
    @State private var orderVM = NewOrderVM()
    @Environment(HostingPlanListVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let context: BillingPlanOrderContext
    private let priceText: String
    private let currencyCode: String?
    @State private var name: String
    
    init(context: BillingPlanOrderContext, priceText: String) {
        self.context = context
        self.priceText = priceText
        self.currencyCode = context.plan.price.first?.currency.symbol
        _name = State(initialValue: context.plan.name)
    }
    
    private var osItems: [(id: Int, title: String)] {
        orderVM.osCategories.flatMap { category in
            category.os.map { item in
                let version = item.version.map { " \($0)" } ?? ""
                return (id: item.id, title: category.name + version)
            }
        }
    }
    
    private var eggsForSelection: [BillingHostingEgg] {
        orderVM.nests.first {
            $0.id == orderVM.selectedNestId
        }?.eggs ?? []
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
                    
                    MonthAmountPicker($orderVM.months)
                }
                
                if context.category == .cloud {
                    Section("Operating system") {
                        if orderVM.isLoadingOptions && osItems.isEmpty {
                            ProgressView()
                        }
                        
                        Picker("OS", selection: $orderVM.selectedOSId) {
                            ForEach(osItems, id: \.id) { // requires id
                                Text($0.title)
                                    .tag($0.id)
                            }
                        }
                    }
                } else {
                    Section("Template") {
                        if orderVM.isLoadingOptions && orderVM.nests.isEmpty {
                            ProgressView()
                        }
                        
                        Picker("Nest", selection: $orderVM.selectedNestId) {
                            ForEach(orderVM.nests) {
                                Text($0.name)
                                    .tag($0.id)
                            }
                        }
                        
                        Picker("Egg", selection: $orderVM.selectedEggId) {
                            ForEach(eggsForSelection) {
                                Text($0.name)
                                    .tag($0.id)
                            }
                        }
                    }
                }
                
                Section {
                    OrderConfirmButton(context) {
                        confetti.launchConfetti()
                    }
                }
            }
            .navigationTitle("Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .environment(orderVM)
            .overlay {
                ConfettiOverlay()
                    .environment(confetti)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadOptions()
            }
            .onChange(of: orderVM.selectedNestId) { _, newValue in
                guard let nest = orderVM.nests.first(where: { $0.id == newValue }) else { return }
                
                if let firstEgg = nest.eggs.first {
                    orderVM.selectedEggId = firstEgg.id
                } else {
                    orderVM.selectedEggId = 0
                }
            }
        }
    }
    
    private func loadOptions() async {
        guard !orderVM.isLoadingOptions else { return }
        
        orderVM.isLoadingOptions = true
        defer { orderVM.isLoadingOptions = false }
        
        let options = await vm.loadOrderOptions(for: context.category, planId: context.plan.id)
        orderVM.osCategories = options.osCategories
        orderVM.nests = options.nests
        
        if orderVM.selectedOSId == 0, let first = options.osCategories.first?.os.first {
            orderVM.selectedOSId = first.id
        }
        
        if orderVM.selectedNestId == 0, let first = options.nests.first {
            orderVM.selectedNestId = first.id
        }
        
        if orderVM.selectedEggId == 0, let first = options.nests.first?.eggs.first {
            orderVM.selectedEggId = first.id
        }
        
        if context.category == .cloud && orderVM.osCategories.isEmpty {
            SystemAlert.error("Unable to load OS list")
        }
        
        if (context.category == .game || context.category == .bot), orderVM.nests.isEmpty {
            SystemAlert.error("No templates available")
        }
    }
    
    private func formatAmount(_ amount: Double, code: String?) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        let value = formatter.string(from: NSNumber(value: amount)) ?? amount.formatted(.fractionDigits(2))
        guard let code else { return value }
        
        return code + value
    }
}
