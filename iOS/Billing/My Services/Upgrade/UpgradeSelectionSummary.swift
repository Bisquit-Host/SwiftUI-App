import SwiftUI

struct UpgradeSelectionSummary: View {
    let name: String
    let priceNow: String
    let monthlyPrice: String
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Selected package")
                    .caption()
                    .secondary()
                
                Text(name)
                    .subheadline(.semibold)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Pay now")
                    .caption()
                    .secondary()
                
                Text(priceNow)
                    .subheadline(.semibold)
                    .monospacedDigit()
                
                Text("\(monthlyPrice)/mo")
                    .caption()
                    .secondary()
                    .monospacedDigit()
            }
        }
        .padding(12)
        .background(.primary.opacity(0.04), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
    }
}

#Preview {
    UpgradeSelectionSummary(name: "Starter Game Server", priceNow: "$4.99", monthlyPrice: "$9.99")
        .padding()
        .darkSchemePreferred()
}
