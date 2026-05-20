import SwiftUI
import ScrechKit

struct UpgradePackage: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(DashboardViewVM.self) private var dashboardVM
    
    let pkg: ChangeablePackage
    @Binding var selectedUpgradeId: Int?
    
    private var isSelected: Bool {
        selectedUpgradeId == pkg.id
    }
    
    var body: some View {
        Button(action: select) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(pkg.name)
                        .subheadline(.semibold)
                    
                    Spacer()
                    
                    Text("\(monthlyPrice)/mo")
                        .subheadline(.semibold)
                        .monospacedDigit()
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(priceBadgeBackground, in: .capsule)
                        .overlay {
                            Capsule()
                                .stroke(priceBadgeBorder, lineWidth: 1)
                        }
                }
                
                FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                    ForEach(specs, id: \.text) { spec in
                        UpgradeSpecChip(spec: spec, isSelected: isSelected)
                    }
                }
                
                HStack(spacing: 6) {
                    Text("Pay now")
                        .caption()
                        .secondary()
                    
                    Text(priceNow)
                        .caption()
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(priceBadgeBackground.opacity(0.6), in: .capsule)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : .primary.opacity(0.03))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accentColor.opacity(0.4) : .primary.opacity(0.08), lineWidth: differentiateWithoutColor && isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func select() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedUpgradeId = pkg.id
        }
    }
    
    private var priceNow: String {
        formatCurrency(max(pkg.price - pkg.toMinus, 0), user: dashboardVM.user)
    }
    
    private var monthlyPrice: String {
        formatCurrency(pkg.price, user: dashboardVM.user)
    }
    
    private var priceBadgeBackground: Color {
        isSelected ? Color.accentColor.opacity(0.12) : .primary.opacity(0.06)
    }
    
    private var priceBadgeBorder: Color {
        isSelected ? Color.accentColor.opacity(0.35) : .primary.opacity(0.12)
    }
    
    private var specs: [(icon: String, text: String)] {
        let ram = "\(formatMegaBytes(pkg.memory)) \(pkg.memoryType ?? "")".trimmingCharacters(in: .whitespaces)
        let disk = "\(formatMegaBytes(pkg.disk)) \(pkg.diskType ?? "")".trimmingCharacters(in: .whitespaces)
        
        var items: [(String, String)] = [
            ("cpu", "\(pkg.cpu.clean) vCPU"),
            ("memorychip", "\(ram) RAM"),
            ("internaldrive", disk)
        ]
        
        if let network = pkg.network {
            let text = pkg.networkType == nil ? "\(network.clean)" : "\(network.clean) \(pkg.networkType ?? "")"
            items.append(("network", text))
        }
        
        if let databases = pkg.databases {
            items.append(("externaldrive.fill", "\(databases) DB's"))
        }
        
        if let backups = pkg.backups {
            items.append(("clock.arrow.circlepath", "\(backups) backups"))
        }
        
        if let allocations = pkg.allocations {
            items.append(("number", "\(allocations) ports"))
        }
        
        return items
    }
}

#Preview {
    @Previewable @State var selectedUpgradeId: Int? = nil
    
    BillingSectionCard("Change plan") {
        UpgradePackage(pkg: .preview, selectedUpgradeId: $selectedUpgradeId)
    }
    .environment(DashboardViewVM())
    .darkSchemePreferred()
}
