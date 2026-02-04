import SwiftUI

struct TopupProviderSheetRow: View {
    let provider: PaymentProvider
    let isSelected: Bool
    let action: () -> Void
    
    private var paymentSystems: [String] {
        switch provider.method?.lowercased() {
        case "card":
            ["Bank cards"]
        
        case "stripe":
            ["Klarna", "Bank cards", "Bank transfers", "iDeal"]
        
        default:
            []
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                TopupProviderIcon(provider)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(provider.name)
                            .subheadline(.semibold)
                        
                        Text(provider.currency.displaySymbol)
                            .footnote()
                            .secondary()
                    }
                    
                    if !paymentSystems.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(paymentSystems, id: \.self) { system in
                                Text(system)
                                    .footnote()
                                    .secondary()
                            }
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primary.opacity(0.2) : .primary.opacity(0.05), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
