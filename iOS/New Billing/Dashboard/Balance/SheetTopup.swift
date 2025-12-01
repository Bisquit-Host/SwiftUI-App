import SwiftUI

struct SheetTopup: View {
    @EnvironmentObject private var store: ValueStore
    private let user: BillingUser
    
    init(_ user: BillingUser) {
        self.user = user
        _selectedProvider = State(initialValue: providers.first)
    }
    
    @State private var vm = SheetTopupVM()
    @State private var amount = ""
    @State private var selectedProvider: PaymentProvider?
    
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
                    TextField("Amount, \(user.currency.uppercased())", text: $amount)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .padding(12)
                        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.primary.opacity(0.05), lineWidth: 1)
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
