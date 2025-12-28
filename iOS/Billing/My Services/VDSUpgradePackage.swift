import ScrechKit

struct UpgradePackage: View {
    @Environment(BillingDashboardVM.self) private var dashboardVM
    
    let pkg: ChangeablePackage
    @Binding var selectedUpgradeId: Int?
    
    private var isSelected: Bool {
        selectedUpgradeId == pkg.id
    }
    
    var body: some View {
        let ram = formatMegaBytes(pkg.memory)
        let disk = formatMegaBytes(pkg.disk)
        let priceNow = formatCurrency(max(pkg.price - pkg.toMinus, 0), user: dashboardVM.user)
        let monthlyPrice = formatCurrency(pkg.price, user: dashboardVM.user)
        
        Button {
            selectedUpgradeId = pkg.id
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pkg.name)
                        .subheadline(.semibold)
                    
                    Text("\(pkg.cpu.clean) vCPU • \(ram) • \(disk)")
                        .footnote()
                        .secondary()
                    
                    Text("Pay now \(priceNow) / \(monthlyPrice)/mo")
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

#Preview {
    @Previewable @State var selectedUpgradeId: Int? = nil
    
    BillingSectionCard("Upgrade") {
        UpgradePackage(pkg: .preview, selectedUpgradeId: $selectedUpgradeId)
    }
    .environment(BillingDashboardVM())
    .darkSchemePreferred()
}
