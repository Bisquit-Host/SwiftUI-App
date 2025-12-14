import SwiftUI

struct GameServiceUpgradePackage: View {
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let pkg: ChangeableGamePackage
    @Binding var selectedUpgradeId: Int?
    
    private var isSelected: Bool {
        selectedUpgradeId == pkg.id
    }
    
    var body: some View {
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
                    
                    Text("Pay now \(formatCurrency(max(pkg.price - pkg.toMinus, 0), user: dashboardVM.user)) / \(formatCurrency(pkg.price, user: dashboardVM.user))/mo")
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
