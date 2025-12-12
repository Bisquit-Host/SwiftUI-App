import SwiftUI

struct VDSUpgradePackage: View {
    let pkg: BillingChangeableCloudPackage
    @Binding var selectedUpgradeId: Int?
    let formatCurrency: (Double) -> String
    
    var body: some View {
        Button {
            selectedUpgradeId = pkg.id
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pkg.name)
                        .subheadline(.semibold)
                    
                    Text("\(pkg.cpu.clean) vCPU • \(pkg.memory.clean) GB • \(Int(pkg.disk)) GB")
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
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedUpgradeId == pkg.id ? Color.accentColor.opacity(0.12) : Color.clear)
            }
        }
        .buttonStyle(.plain)
    }
}
