import SwiftUI

struct HostingOrderSheet: View {
    @State private var confetti = ConfettiVM()
    @Environment(HostingPlanListVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let context: BillingPlanOrderContext
    private let priceText: String
    private let currencyCode: String?
    
    init(context: BillingPlanOrderContext, priceText: String) {
        self.context = context
        self.priceText = priceText
        self.currencyCode = context.plan.price.first?.currency.symbol
        _name = State(initialValue: context.plan.name)
    }
    
    @State private var name: String
    @State private var months = 1
    @State private var osCategories: [CloudServiceOSCategory] = []
    @State private var nests: [BillingHostingNest] = []
    @State private var selectedOSId = 0
    @State private var selectedNestId = 0
    @State private var selectedEggId = 0
    @State private var isLoadingOptions = false
    @State private var isOrdering = false
    @State private var alertPurchase = false
    
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
                    
                    MonthAmountPicker($months)
                }
                
                if context.category == .cloud {
                    Section("Operating system") {
                        if isLoadingOptions && osItems.isEmpty {
                            ProgressView()
                        }
                        
                        Picker("OS", selection: $selectedOSId) {
                            ForEach(osItems, id: \.id) { // requires id
                                Text($0.title)
                                    .tag($0.id)
                            }
                        }
                    }
                } else {
                    Section("Template") {
                        if isLoadingOptions && nests.isEmpty {
                            ProgressView()
                        }
                        
                        Picker("Nest", selection: $selectedNestId) {
                            ForEach(nests) {
                                Text($0.name)
                                    .tag($0.id)
                            }
                        }
                        
                        Picker("Egg", selection: $selectedEggId) {
                            ForEach(eggsForSelection) {
                                Text($0.name)
                                    .tag($0.id)
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        alertPurchase = true
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
            .onChange(of: selectedNestId) { _, newValue in
                guard let nest = nests.first(where: { $0.id == newValue }) else { return }
                
                if let firstEgg = nest.eggs.first {
                    selectedEggId = firstEgg.id
                } else {
                    selectedEggId = 0
                }
            }
            .alert("Confirm purchase", isPresented: $alertPurchase) {
                Button("Confirm", role: .confirm, action: confirmPurchase)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Purchase \(context.plan.name) for \(months) billing?")
            }
        }
    }
    
    private func confirmPurchase() {
        Task {
            await order {
                confetti.launchConfetti()
            }
        }
    }
    
    private func loadOptions() async {
        guard !isLoadingOptions else { return }
        
        isLoadingOptions = true
        defer { isLoadingOptions = false }
        
        let options = await vm.loadOrderOptions(for: context.category, planId: context.plan.id)
        osCategories = options.osCategories
        nests = options.nests
        
        if selectedOSId == 0, let first = options.osCategories.first?.os.first {
            selectedOSId = first.id
        }
        
        if selectedNestId == 0, let first = options.nests.first {
            selectedNestId = first.id
        }
        
        if selectedEggId == 0, let first = options.nests.first?.eggs.first {
            selectedEggId = first.id
        }
        
        if context.category == .cloud && osCategories.isEmpty {
            SystemAlert.error("Unable to load OS list")
        }
        
        if (context.category == .game || context.category == .bot), nests.isEmpty {
            SystemAlert.error("No templates available")
        }
    }
    
    private func order(onSuccess: @escaping () -> Void) async {
        guard !isOrdering else { return }
        
        isOrdering = true
        defer { isOrdering = false }
        
        let response = await vm.order(
            context: context,
            name: name,
            months: months,
            osId: selectedOSId == 0 ? nil : selectedOSId,
            nestId: selectedNestId == 0 ? nil : selectedNestId,
            eggId: selectedEggId == 0 ? nil : selectedEggId
        )
        
        guard let response else {
            SystemAlert.error("Unable to complete order")
            return
        }
        
        print(response)
        onSuccess()
        
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            dismiss()
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
        nests.first {
            $0.id == selectedNestId
        }?.eggs ?? []
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
