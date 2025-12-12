import SwiftUI

struct GameServiceUpgradePackage: View {
    let package: BillingChangeableGamePackage
    @Binding var selectedUpgradeId: Int?
    let formatCurrency: (Double) -> String
    
    private var isSelected: Bool {
        selectedUpgradeId == package.id
    }
    
    var body: some View {
        Button {
            selectedUpgradeId = package.id
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.name)
                        .subheadline(.semibold)
                    
                    Text("\(package.cpu.clean) vCPU • \(package.memory.clean) GB • \(package.disk.clean) GB")
                        .footnote()
                        .secondary()
                    
                    Text("Pay now \(formatCurrency(max(package.price - package.toMinus, 0))) / \(formatCurrency(package.price))/mo")
                        .footnote()
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
            }
        }
        .buttonStyle(.plain)
    }
}
