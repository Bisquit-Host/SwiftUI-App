import SwiftUI

struct BillingGameServiceDetailView: View {
    @State private var vm = BillingGameServiceDetailVM()
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let serviceId: Int
    
    @State private var pendingName = ""
    @State private var renewMonths = 1
    @State private var lastRenewAmount: Double?
    @State private var selectedUpgradeId: Int?
    @State private var alertRename = false
    @State private var alertRenew = false
    @State private var alertUpgrade = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let service = vm.service {
                    header(service)
                    detailsSection(service)
                    billingSection(service)
                    upgradeSection(service)
                    
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                }
                
                if let message = vm.actionMessage {
                    Text(message)
                        .footnote()
                        .foregroundStyle(.green)
                }
                
                if let error = vm.lastError {
                    Text(error)
                        .footnote()
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle(vm.service?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .refreshableTask {
            await vm.load(serviceId)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if vm.isPerformingAction {
                    ProgressView()
                } else {
                    Menu {
                        Button("Rename", systemImage: "pencil") {
                            alertRename = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        .onChange(of: vm.service?.id) { _, _ in
            if let service = vm.service {
                pendingName = service.name
                selectedUpgradeId = vm.changeablePackages.first?.id
                renewMonths = 1
            }
        }
        .onChange(of: vm.changeablePackages.count) { _, _ in
            if selectedUpgradeId == nil {
                selectedUpgradeId = vm.changeablePackages.first?.id
            }
        }
        .alert("Rename service", isPresented: $alertRename, presenting: vm.service) { service in
            TextField("New name", text: $pendingName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Button("Save") {
                Task {
                    await vm.rename(pendingName.isEmpty ? service.name : pendingName, serviceId: service.id)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .alert("Extend service", isPresented: $alertRenew) {
            Button("Confirm payment") {
                guard let service = vm.service else { return }
                
                Task {
                    if let response = await vm.renew(months: renewMonths, serviceId: service.id) {
                        lastRenewAmount = response.amount
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Extend \(vm.service?.name ?? "this service") for \(renewMonths) \(renewMonths == 1 ? "month" : "months")?")
        }
        .alert("Confirm upgrade", isPresented: $alertUpgrade) {
            Button("Upgrade") {
                guard let pkg = selectedUpgradePackage else { return }
                
                Task {
                    await vm.changePackage(to: pkg.id, serviceId: serviceId)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            if let pkg = selectedUpgradePackage {
                Text("Upgrade to \(pkg.name) and pay \(formatCurrency(max(pkg.price - pkg.toMinus, 0))) now?")
            } else {
                Text("Upgrade service?")
            }
        }
    }
    
    // MARK: - Sections
    
    private func header(_ service: BillingGameServiceDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(service.name)
                    .title3(.bold)
                
                Spacer()
                
                Capsule()
                    .fill(service.state.color.opacity(0.15))
                    .overlay {
                        Text(service.state.title)
                            .footnote(.semibold)
                            .foregroundStyle(service.state.color)
                            .padding(.horizontal, 10)
                    }
                    .frame(height: 30)
            }
            
            HStack(spacing: 10) {
                Text(service.packageInfo.name)
                    .footnote()
                    .secondary()
                
                if let flag = service.location.flagUrl, let url = URL(string: flag) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .frame(width: 24, height: 16)
                            .clipShape(.rect(cornerRadius: 3))
                    } placeholder: {
                        Color.gray.opacity(0.15)
                            .frame(width: 24, height: 16)
                            .clipShape(.rect(cornerRadius: 3))
                    }
                }
                
                Text(service.location.name)
                    .footnote()
                    .secondary()
            }
        }
    }
    
    private func detailsSection(_ service: BillingGameServiceDetails) -> some View {
        BillingSectionCard("Details") {
            VStack(alignment: .leading, spacing: 10) {
                row(title: "Package", value: service.packageInfo.name)
                row(title: "CPU", value: "\(service.packageInfo.cpu.clean) vCPU \(service.packageInfo.cpuName ?? "")")
                row(title: "RAM", value: "\(service.packageInfo.memory.clean) GB")
                row(title: "Disk", value: "\(service.packageInfo.disk.clean) GB \(service.packageInfo.diskType ?? "")")
                row(title: "Network", value: "\(service.packageInfo.network.clean) \(service.packageInfo.networkType ?? "")")
                
                if let expires = service.expiresAt {
                    row(title: "Expires", value: expires.formatted(date: .numeric, time: .shortened))
                }
            }
        }
    }
    
    private func billingSection(_ service: BillingGameServiceDetails) -> some View {
        BillingSectionCard("Billing") {
            Toggle(isOn: Binding(
                get: { vm.service?.autorenew ?? service.autorenew },
                set: { newValue in Task { await vm.changeAutorenew(newValue, serviceId: service.id) } }
            )) {
                Text("Auto-extend monthly")
            }
            .toggleStyle(.switch)
            .disabled(vm.isPerformingAction)
            
            VStack(alignment: .leading, spacing: 8) {
                Picker("Extend for", selection: $renewMonths) {
                    ForEach([1, 3, 6, 12], id: \.self) { value in
                        Text(value == 1 ? "1 month" : "\(value) months")
                            .tag(value)
                    }
                }
                .pickerStyle(.menu)
                
                Button {
                    alertRenew = true
                } label: {
                    if vm.isPerformingAction {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Pay and extend")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isPerformingAction)
                
                if let expires = vm.service?.expiresAt ?? service.expiresAt {
                    Text("Expires \(expires.formatted(date: .numeric, time: .shortened))")
                        .footnote()
                        .secondary()
                }
                
                if let lastRenewAmount {
                    Text("Charged \(formatCurrency(lastRenewAmount))")
                        .footnote()
                        .foregroundStyle(.green)
                }
            }
        }
    }
    
    private func upgradeSection(_ service: BillingGameServiceDetails) -> some View {
        BillingSectionCard("Upgrade") {
            if vm.changeablePackages.isEmpty {
                Text("No higher packages available right now")
                    .footnote()
                    .secondary()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(vm.changeablePackages) { pkg in
                        Button {
                            selectedUpgradeId = pkg.id
                        } label: {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pkg.name)
                                        .subheadline(.semibold)
                                    
                                    Text("\(pkg.cpu.clean) vCPU • \(pkg.memory.clean) GB • \(pkg.disk.clean) GB")
                                        .footnote()
                                        .secondary()
                                    
                                    Text("Pay now \(formatCurrency(max(pkg.price - pkg.toMinus, 0))) / \(formatCurrency(pkg.price))/mo")
                                        .footnote()
                                        .foregroundStyle(.primary)
                                }
                                
                                Spacer()
                                
                                if selectedUpgradeId == pkg.id {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedUpgradeId == pkg.id ? Color.accentColor.opacity(0.12) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button {
                        if selectedUpgradeId != nil {
                            alertUpgrade = true
                        }
                    } label: {
                        if vm.isPerformingAction {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Upgrade")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedUpgradeId == nil || vm.isPerformingAction)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func row(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .footnote()
                .secondary()
            
            Spacer()
            
            Text(value)
                .footnote()
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let value = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        
        if let user = dashboardVM.user {
            return user.currency.symbol + value
        } else {
            return value
        }
    }
    
    private var selectedUpgradePackage: BillingChangeableGamePackage? {
        vm.changeablePackages.first { $0.id == selectedUpgradeId }
    }
}

#Preview {
    NavigationStack {
        BillingGameServiceDetailView(serviceId: 1)
            .environment(BillingDashboardVM())
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
