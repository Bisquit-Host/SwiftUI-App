import SwiftUI

struct HostingOrderSheet: View {
    @State private var confetti = ConfettiVM()
    @State private var orderVM = NewOrderVM()
    @Environment(HostingPlanListVM.self) private var vm
    @Environment(DashboardViewVM.self) private var dashboardVM
    
    private let context: BillingPlanOrderContext
    private let priceText: String
    private let currencyCode: String?
    @State private var name: String
    @State private var sheetTopup = false
    @State private var showTopupAlert = false
    
    init(context: BillingPlanOrderContext, priceText: String) {
        self.context = context
        self.priceText = priceText
        self.currencyCode = context.plan.price.first?.currency.symbol
        _name = State(initialValue: context.plan.name)
    }
    
    var body: some View {
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
                    HostingOrderSheetOSPicker()
                }
            } else {
                Section("Template") {
                    if orderVM.isLoadingOptions && orderVM.nests.isEmpty {
                        ProgressView()
                    }
                    
                    HostingOrderSheetNestPicker()
                    HostingOrderSheetEggPicker()
                }
            }
            
            Section {
                OrderConfirmButton(context, onSuccess: confetti.launchConfetti)
            }
        }
        .navigationTitle("Purchase")
        .navigationBarTitleDisplayMode(.inline)
        .environment(orderVM)
        .task {
            await loadOptions()
        }
        .overlay {
            ConfettiOverlay()
                .environment(confetti)
        }
        .onChange(of: orderVM.selectedNestId) { _, newValue in
            guard let nest = orderVM.nests.first(where: { $0.id == newValue }) else { return }
            
            if let firstEgg = nest.eggs.first {
                orderVM.selectedEggId = firstEgg.id
            } else {
                orderVM.selectedEggId = 0
            }
        }
        .onAppear {
            showTopupAlert = vm.topupAlertContext == .purchase
        }
        .onChange(of: vm.topupAlertContext) { _, newValue in
            showTopupAlert = newValue == .purchase
        }
        .onChange(of: showTopupAlert) { _, newValue in
            if !newValue, vm.topupAlertContext == .purchase {
                vm.topupAlertContext = nil
            }
        }
        .alert("Insufficient funds", isPresented: $showTopupAlert) {
            Button("Dismiss", role: .cancel) {}
            Button("Top up") {
                vm.topupAlertContext = nil
                sheetTopup = true
            }
        } message: {
            Text("Add funds to continue")
        }
        .sheet($sheetTopup) {
            NavigationStack {
                if let user = dashboardVM.user {
                    SheetTopup(user)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}
