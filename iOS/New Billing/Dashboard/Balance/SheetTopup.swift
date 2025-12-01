import SwiftUI

struct SheetTopup: View {
    @EnvironmentObject private var store: ValueStore
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
        _selectedProvider = State(initialValue: providers.first)
    }
    
    @State private var vm = SheetTopupVM()
    @State private var amount = "50"
    @State private var selectedProvider: PaymentProvider?
    
    private let amountFieldSide: CGFloat = 48
    
    private let providers = [
        PaymentProvider(id: "tbank", name: "Tbank", image: .tbank, tint: .yellow),
        PaymentProvider(id: "tbank2", name: "Tbank", image: .tbank, tint: .yellow)
    ]
    
    var body: some View {
        ScrollView {
            BillingSectionCard("Balance") {
                BillingAccountRow("Main", icon: "creditcard.fill", tint: .blue, value: formatted(user.balance))
                BillingAccountRow("Bonus", icon: "sparkles", tint: .mint, value: formatted(user.bonusBalance))
                BillingAccountRow("Total", icon: "wallet.pass.fill", tint: .indigo, value: formatted(user.totalBalance))
            }
            
            BillingSectionCard("Top up") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        TextField("Amount, \(user.currency.uppercased())", text: $amount)
                            .keyboardType(.decimalPad)
                            .textInputAutocapitalization(.never)
                            .padding(12)
                            .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.primary.opacity(0.05), lineWidth: 1)
                            }
                            .frame(height: amountFieldSide)
                        
                        HStack(spacing: 8) {
                            Button {
                                adjustAmount(by: -stepAmount)
                            } label: {
                                Image(systemName: "minus")
                                    .frame(amountFieldSide)
                            }
                            .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                            .disabled(Double(amount) ?? 0 <= stepAmount)
                            
                            Button {
                                adjustAmount(by: stepAmount)
                            } label: {
                                Image(systemName: "plus")
                                    .frame(amountFieldSide)
                            }
                            .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                        }
                        .foregroundStyle(.foreground)
                        .frame(width: amountFieldSide * 2 + 8)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(providers) {
                                TopupProviderCard($0, selectedProvider: $selectedProvider)
                            }
                        }
                    }
                    
                    Button {
                        topUp()
                    } label: {
                        Text("Top up")
                            .foregroundStyle(.white)
                            .rounded()
                            .semibold()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 6)
                    .buttonStyle(.glassProminent)
                    .tint(.green)
                    .disabled(amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedProvider == nil)
                }
            }
            
            if vm.isLoading && vm.operations.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                
            } else if vm.operations.isEmpty {
                ContentUnavailableView("No operations yet", systemImage: "creditcard")
                    .listRowBackground(Color.clear)
                
            } else {
                BillingSectionCard("Operations") {
                    ForEach(Array(vm.operations.enumerated()), id: \.element.id) { index, operation in
                        BillingOperationRow(operation)
                        
                        if index < vm.operations.count - 1 {
                            Divider()
                        }
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
            }
        }
        .scenePadding()
        .task {
            await vm.fetchOperations(accessToken: store.testAccessToken)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
            
            ToolbarSpacer(.flexible, placement: .bottomBar)
        }
    }
    
    private func topUp() {
        
    }
    
    private func adjustAmount(by delta: Double) {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        let current = Double(normalized) ?? 0
        let updated = max(0, current + delta)
        amount = String(format: "%.2f", updated)
    }
    
    private var stepAmount: Double {
        user.currency.uppercased() == "RUB" ? 50 : 5
    }
    
    private func formatted(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.currencyCode = user.currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: amount as NSNumber) ?? "\(amount)"
    }
}

#Preview {
    SheetTopup(.preview)
        .environmentObject(ValueStore())
        .darkSchemePreferred()
}
